json.extract! user, :id, :first_name, :last_name, :email, :gender, :hobbies, :created_at, :updated_at
json.addresses user.addresses, partial: 'addresses/address', as: :address
json.url user_url(user, format: :json)
