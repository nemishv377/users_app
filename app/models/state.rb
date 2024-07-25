class State < ApplicationRecord
  has_many :cities
  has_many :addresses
  validates_associated :users
  validates_associated :cities
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  
end
