class State < ApplicationRecord
  has_many :cities
  has_many :users
  accepts_nested_attributes_for :cities, :users
  validates_associated :users
  validates_associated :cities
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  
end
