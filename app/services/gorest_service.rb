class GorestService
  BASE_URL = 'https://gorest.co.in/public/v2/users'.freeze

  def initialize
    @connection = Faraday.new(url: BASE_URL) do |conn|
      conn.request :json
      conn.response :json, content_type: /\bjson$/
      conn.headers['Authorization'] = 'Bearer 12b90432857c3ff89e83e2da58a8c74242408725e56e11fc02631972d88d971b' # Replace with actual API token
      conn.headers['Content-Type'] = 'application/json'
      conn.adapter Faraday.default_adapter
    end
  end

  # Fetch all users
  def fetch_users
    response = @connection.get('/users')
    handle_response(response)
  end

  # Fetch a single user by ID
  def fetch_user(user_id)
    response = @connection.get("/users/#{user_id}")
    handle_response(response)
  end

  # Create a new user
  def create_user(user_params)
    response = @connection.post('/users', user_params.to_json)
    handle_response(response)
  end

  # Update an existing user
  def update_user(user_id, user_params)
    response = @connection.put("/users/#{user_id}", user_params.to_json)
    handle_response(response)
  end

  # Delete a user
  def delete_user(user_id)
    response = @connection.delete("/users/#{user_id}")
    handle_response(response)
  end

  private

  def handle_response(response)
    case response.status
    when 200..299
      { success: true, data: response.body }
    else
      { success: false, error: response.body }
    end
  end
end
