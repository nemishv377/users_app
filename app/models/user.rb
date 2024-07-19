class User < ApplicationRecord
  has_many :addresses ,dependent: :destroy
  belongs_to :state
  belongs_to :city
  serialize :hobbies, Array, coder: YAML
  accepts_nested_attributes_for :addresses, allow_destroy: true, reject_if: proc { |attributes| attributes['street_name'].blank? }
  validates_associated :addresses

  def addresses_attributes=(addresses_attributes)
    addresses_attributes.each do |i,address_attributes|
      @ad_id =  address_attributes[:id]
      puts i,address_attributes[:_destroy]
      if @ad_id.nil?
        self.addresses.build(address_attributes)
        break
      else
        Address.find_by(id: @ad_id).destroy
      end
      self.addresses.build(address_attributes)
      
    end
  end
  
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
