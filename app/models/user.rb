class User < ApplicationRecord
  
  belongs_to :state
  belongs_to :city
  serialize :hobbies, Array, coder: YAML
  accepts_nested_attributes_for :state, :city
  
  # attr_accessor :state_name
  # attr_accessor :city_name
  # # attr_accessor :state_id
  # before_save :update_state_attributes, :update_city_attributes

  # def state_name
  #   state.name if state
  # end

  # def state_name=(name)
  #   @state_name = name
  # end

  # def city_name
  #   city.name if city
  # end

  # def city_name=(name)
  #   @city_name = name
  # end

  # # def city_state_id
  # #   city.state_id if city
  # # end

  # # def city_state_id=(id)
  # #   @city_state_id = id
  # # end



  # private
  # def update_state_attributes
  #   if state
  #     state.update(state: @state_name)
  #   end
  # end

  # def update_city_attributes
  #   if city
  #     city.update(city: @city_name)
  #   end
  # end

  
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
  validates :state, presence: true
  validates :city, presence: true

end
