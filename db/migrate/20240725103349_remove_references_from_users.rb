class RemoveReferencesFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_reference :users, :state, null: false, foreign_key: true
    remove_reference :users, :city, null: false, foreign_key: true
  end
end
