class City < ApplicationRecord
  belongs_to :state
  has_many :addresses
  default_scope -> { order(:name) }
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
