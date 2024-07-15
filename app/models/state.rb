class State < ApplicationRecord
  has_many :cities, inverse_of: :State
  has_many :users, inverse_of: :State
  accepts_nested_attributes_for :users, allow_destroy: true
  accepts_nested_attributes_for :cities, allow_destroy: true
  validates_associated :users
  validates_associated :cities
  default_scope -> { order(:name) }
end
