class User < ApplicationRecord
  has_many :addresses ,dependent: :destroy
  belongs_to :state
  belongs_to :city
  serialize :hobbies, Array, coder: YAML
  accepts_nested_attributes_for :addresses, reject_if: :all_blank, allow_destroy: true
  
  VALID_GENDERS = ['Male', 'Female', 'Other']
  VALID_HOBBIES = ['reading','travelling','photography']
  VALID_STATES = State.all
  VALID_CITIES = City.all

  
  validates :first_name, presence: true, length: { minimum: 2, maximum: 50, message: "must be between 2 and 50 characters" },
                         format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters" }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50, message: "must be between 2 and 50 characters" },
                         format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters" }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { case_sensitive: false }
  validates :gender, presence: true, inclusion: { in: VALID_GENDERS, message: "%{value} is not a valid gender" }
  validates :hobbies, presence: true, inclusion: { in: VALID_HOBBIES, message: "%{value} is not a valid Hobby." }
  validates :state, presence: true, inclusion: { in: VALID_STATES, message: "%{value} is not a valid State." }
  validates :city, presence: true, inclusion: { in: VALID_CITIES, message: "%{value} is not a valid City." }

end
