json.extract! user, :id, :first_name, :last_name, :email, :gender, :hobbies, :created_at, :updated_at
json.addresses user.addresses, partial: 'api/v1/addresses/address', as: :address
json.url api_v1_user_url(user)
