class State < ApplicationRecord
  has_many :cities
  has_many :addresses
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  
end
