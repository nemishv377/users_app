json.extract! user, :id, :first_name, :last_name, :email, :gender, :hobbies, :created_at, :updated_at
if user.avatar.attached?
  json.avatar_url url_for(user.avatar)
else
  json.avatar_url nil
end
json.addresses user.addresses, partial: 'addresses/address', as: :address
json.url api_v1_user_url(user)
