class AddStateAndCityReferencesToAddresses < ActiveRecord::Migration[7.1]
  def change
    add_reference :addresses, :state, null: false, foreign_key: true, default: 1
    add_reference :addresses, :city, null: false, foreign_key: true, default: 1
  end
end
