class AddLinkedinTokensToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :linkedin_oauth_token, :string
    add_column :users, :linkedin_oauth_token_expires_at, :datetime
  end
end
