class RemoveReferencesFromAddresses < ActiveRecord::Migration[7.1]
  def change
    remove_reference :addresses, :state, null: false, foreign_key: true
    remove_reference :addresses, :city, null: false, foreign_key: true
  end
end
