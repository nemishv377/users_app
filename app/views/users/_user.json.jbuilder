json.extract! user, :id, :first_name, :last_name, :email, :gender, :hobbies, :state_id, :city_id, :created_at, :updated_at
json.url user_url(user, format: :json)
