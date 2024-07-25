class Address < ApplicationRecord
  belongs_to :user
  VALID_STATES = State.all.pluck(:id)
  VALID_CITIES = City.all.pluck(:id)

  validates :plot_no, presence: { message: "Plot no can't be blank." }, format: { with:  /\A[a-zA-Z0-9]+\z/, message: "Plot no only allows alphanumeric characters" }
  validates :society_name, presence: { message: "Society name can't be blank." }
  validates :pincode, presence: { message: "Pincode can't be blank." }, format: { with: /\A\d{6}\z/, message: "Pincode should be 6 digits long" }, length: { is: 6 }
  validates :state_id, presence: true, inclusion: { in: VALID_STATES, message: "%{value} is not a valid State." }
  validates :city_id, presence: true, inclusion: { in: VALID_STATES, message: "%{value} is not a valid State." }
end
