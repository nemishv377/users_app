class User < ApplicationRecord
  belongs_to :state
  belongs_to :city
  serialize :hobbies, Array, coder: YAML
  # validates :first_name, presence: true
  # validates :last_name, presence: true
  # validates :gender, presence: true
  
end
