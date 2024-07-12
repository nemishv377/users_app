class City < ApplicationRecord
  belongs_to :state
  has_many :users
  default_scope -> { order(:name) }
end
