class User < ActiveRecord::Base

  validates :username, :password_digest, :session_token, presence: true
  validates :password, length: { minimum: 6, allow_nil: true }
  validates :session_token, :username, uniqueness: true

  attr_reader :password

  after_initialize :ensure_session_token

  has_many :products,
    foreign_key: :author_id,
    primary_key: :id,
    class_name: 'Product',
  dependent: :destroy

  has_many :comments,
    foreign_key: :user_id,
    primary_key: :id,
    class_name: 'Comment',
  dependent: :destroy

  def self.find_by_credentials(username, password)
    user = User.find_by(username: username)
    return nil unless user && user.is_password?(password)
    user
  end

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def is_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end

  def reset_session_token!
    self.session_token = SecureRandom.urlsafe_base64(16)
    self.save!
    self.session_token
  end

  private
  def ensure_session_token
    self.session_token ||= SecureRandom.urlsafe_base64(16)
  end

end
