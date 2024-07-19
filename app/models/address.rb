class Address < ApplicationRecord
  belongs_to :user

  validates :plot_no, presence: true, format: { with:  /\A[a-zA-Z0-9]+\z/, message: "only allows alphanumeric characters" }
  validates :society_name, presence: true
  validates :pincode, presence: true, length: { is: 6 }, format: { with: /\A\d{6}\z/, message: "should be 6 digits long" }
end
