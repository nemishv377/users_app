class Address < ApplicationRecord
  belongs_to :user
  belongs_to :state
  belongs_to :city

  scope :default, -> { where(default: true) }
  scope :except_default, -> { where(default: false) }
  before_validation :unset_other_defaults, if: :default?

  validates :plot_no, presence: { message: "Plot no can't be blank." },
                      format: { with: /\A[a-zA-Z0-9]+\z/, message: 'Plot no only allows alphanumeric characters' }
  validates :society_name, presence: { message: "Society name can't be blank." }
  validates :pincode, presence: { message: "Pincode can't be blank." },
                      format: { with: /\A\d{6}\z/, message: 'Pincode should be 6 digits long' }, length: { is: 6 }
  validates :state_id, presence: { message: "State can't be empty." }
  validates :city_id, presence: { message: "City can't be empty." }
  validates :default, uniqueness: { scope: :user_id, message: 'There can be only one default address' }, if: :default?

  private

  def unset_other_defaults
    user.addresses.where.not(id:).update_all(default: false)
  end
end
