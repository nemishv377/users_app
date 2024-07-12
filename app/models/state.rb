class State < ApplicationRecord
  has_many :cities, inverse_of: :State
  has_many :users, inverse_of: :State
  default_scope -> { order(:name) }
end
