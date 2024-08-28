class User < ApplicationRecord
  rolify
  # has_secure_password
  after_create :assign_default_role, :send_welcome_email

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:google_oauth2]

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

  def profile_avatar_content_type
    return unless avatar.attached? && !avatar.content_type.in?(%w[image/jpeg image/png])

    errors.add(:avatar, 'must be a JPEG or PNG')
  end

  def self.from_google(auth)
    email = auth.info.email
    first_name = auth.info.first_name
    last_name = auth.info.last_name
    gender = auth.info.gender

    user = User.find_or_initialize_by(email:) do |u|
      u.first_name = first_name
      u.last_name = last_name
      u.gender = gender
      u.hobbies = ['Reading']
      u.password = 12_345_678
      # u.addresses[0].plot_no = 123
      # u.addresses[0].society_name = 'Your society name'
      # u.addresses[0].pincode = 'pincode'
      # u.addresses[0].state_id = 1
      # u.addresses[0].city_id = 1
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
