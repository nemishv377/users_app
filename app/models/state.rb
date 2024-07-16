class State < ApplicationRecord
  has_many :cities
  has_many :users
  validates_associated :users
  validates_associated :cities
  
end
