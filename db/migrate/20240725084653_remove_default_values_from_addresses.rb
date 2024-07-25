class RemoveDefaultValuesFromAddresses < ActiveRecord::Migration[7.1]
  def change
    change_column_default :addresses, :state_id, nil
    change_column_default :addresses, :city_id, nil
  end
end
