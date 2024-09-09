class User < ApplicationRecord
  rolify
  include DeepCloneable
  include Discard::Model
  # has_secure_password
  after_create :assign_default_role, :send_welcome_email

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: %i[google_oauth2 github linkedin facebook]

  has_one_attached :avatar
  has_many :addresses, dependent: :destroy
  serialize :hobbies, Array, coder: YAML
  accepts_nested_attributes_for :addresses, allow_destroy: true

  VALID_GENDERS = %w[Male Female Other]
  VALID_HOBBIES = %w[Reading Travelling Photography]
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/

  validates :first_name, presence: true,
                         length: { minimum: 2, maximum: 50, message: 'must be between 2 and 50 characters' }
  validates :last_name, presence: true,
                        length: { minimum: 2, maximum: 50, message: 'must be between 2 and 50 characters' }
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :gender, presence: true
  validates :hobbies, presence: true
  validate :profile_avatar_content_type
  validate :must_have_at_least_one_address

  attr_accessor :skip_password_validation

  # Override Devise's method to add custom validation skipping
  def password_required?
    return false if skip_password_validation

    super
  end

  def profile_avatar_content_type
    return unless avatar.attached? && !avatar.content_type.in?(%w[image/jpeg image/png])

    errors.add(:avatar, 'must be a JPEG or PNG')
  end

  def active_for_authentication?
    super && !discarded?
  end

  def self.from_google(auth)
    find_or_initialize_user(auth, 'google', nil)
  end

  def self.from_github(auth)
    find_or_initialize_user(auth, auth.provider, nil)
  end

  def self.from_linkedin(auth)
    find_or_initialize_user(auth, auth.provider, auth.credentials.token)
  end

  def self.from_facebook(auth)
    find_or_initialize_user(auth, auth.provider, nil)
  end

  def self.find_or_initialize_user(auth, provider, linkedin_token)
    user = User.find_or_initialize_by(uid: auth.uid) do |u|
      u.first_name = auth.info.first_name || auth.info.name
      u.last_name = auth.info.last_name
      u.email = auth.info.email if auth.info.email
      u.hobbies = ['Reading']
      u.password = 12_345_678
      u.provider = provider
      u.uid = auth.uid
      u.gender = auth.extra.raw_info.gender.capitalize if provider == 'facebook'
      u.linkedin_oauth_token = linkedin_token if linkedin_token
      u.linkedin_oauth_token_expires_at = Time.at(auth.credentials.expires_at) if linkedin_token
    end

    user.save!(validate: false)
    user
  end

  private

  def assign_default_role
    add_role(:student) if roles.blank?
  end

  def send_welcome_email
    SendUserWelcomeEmailJob.perform_later(self)
    # UserMailer.welcome_email(self).deliver_later
  end

  def must_have_at_least_one_address
    return unless addresses.empty?

    errors.add(:addresses, 'must have at least one valid address')
  end
end
