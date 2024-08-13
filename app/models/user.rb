class User < ApplicationRecord
  rolify
  after_create :assign_default_role

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar
  has_many :addresses, dependent: :destroy
  serialize :hobbies, Array, coder: YAML
  accepts_nested_attributes_for :addresses, allow_destroy: true

  VALID_GENDERS = %w[Male Female Other]
  VALID_HOBBIES = %w[Reading Travelling Photography]
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :first_name, presence: true,
                         length: { minimum: 2, maximum: 50, message: 'must be between 2 and 50 characters' }
  validates :last_name, presence: true,
                        length: { minimum: 2, maximum: 50, message: 'must be between 2 and 50 characters' }
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :gender, presence: true
  validates :hobbies, presence: true
  validate :profile_avatar_content_type

  def profile_avatar_content_type
    return unless avatar.attached? && !avatar.content_type.in?(%w[image/jpeg image/png])

    errors.add(:avatar, 'must be a JPEG or PNG')
  end

  private

  def assign_default_role
    add_role(:student) if roles.blank?
  end
end
