class AddDefaultToAddresses < ActiveRecord::Migration[7.1]
  def change
    add_column :addresses, :default, :boolean
  end
end
