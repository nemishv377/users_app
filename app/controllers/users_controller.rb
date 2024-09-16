require 'csv'
class UsersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :user_not_found

  before_action :authenticate_user!

  # GET /users or /users.json
  def index
    response = Faraday.get('https://gorest.co.in/public/v2/users') do |req|
      req.headers['Authorization'] = 'Bearer 12b90432857c3ff89e83e2da58a8c74242408725e56e11fc02631972d88d971b'
      req.headers['Content-Type'] = 'application/json'
      req.options.timeout = 30
      req.options.open_timeout = 10
      req.params['page'] = 1
      req.params['per_page'] = 20
    end

    if response.success?
      @users = JSON.parse(response.body)
    else
      @users = []
      flash[:alert] = "Failed to fetch users: #{response.status}"
    end
  end

  # GET /users/1 or /users/1.json
  def show
    user_id = params[:id].to_i
    response = Faraday.get("https://gorest.co.in/public/v2/users/#{user_id}") do |req|
      req.headers['Authorization'] = 'Bearer 12b90432857c3ff89e83e2da58a8c74242408725e56e11fc02631972d88d971b'
      req.headers['Content-Type'] = 'application/json'
      req.options.timeout = 30
      req.options.open_timeout = 10
    end
    if response.success?
      @user = JSON.parse(response.body)
    else
      @user = []
      flash[:alert] = "Failed to fetch users: #{response.status}"
    end
    @user = JSON.parse(response.body)
    puts "response.body#{response.body}"
  end

  # GET /users/new
  def new
    @user = OpenStruct.new
  end

  # GET /users/1/edit
  def edit
    user_id = params[:id].to_i
    response = Faraday.get("https://gorest.co.in/public/v2/users/#{user_id}") do |req|
      req.headers['Authorization'] = 'Bearer 12b90432857c3ff89e83e2da58a8c74242408725e56e11fc02631972d88d971b'
      req.headers['Content-Type'] = 'application/json'
      req.options.timeout = 30
      req.options.open_timeout = 10
    end
    if response.success?
      user_data = JSON.parse(response.body)
      @user = OpenStruct.new(user_data)
    else
      @user = []
      flash[:alert] = "Failed to fetch users: #{response.status}"
      redirect_to users_path
    end
    puts @user
  end

  # POST /users or /users.json
  def create
    response = create_user_in_third_party_api(user_params)

    if response.is_a?(Faraday::Response) && response.success?
      flash[:notice] = 'User created successfully in third-party system!'
      redirect_to users_path
    else
      flash[:alert] = "Error creating user: #{response.body}"
      redirect_to new_user_path
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    user_id = params[:id].to_i

    response = Faraday.put("https://gorest.co.in/public/v2/users/#{user_id}") do |req|
      req.headers['Authorization'] = 'Bearer 12b90432857c3ff89e83e2da58a8c74242408725e56e11fc02631972d88d971b'
      req.headers['Content-Type'] = 'application/json'
      req.body = user_params.to_json
      req.options.timeout = 30
      req.options.open_timeout = 10
    end

    puts response.body

    if response.is_a?(Faraday::Response) && response.success?
      flash[:notice] = 'User updated successfully in third-party system!'
      redirect_to users_path
    else
      flash[:alert] = "Error while editting user: #{response.body}"
      redirect_to edit_user_path
    end
  end

  def update_avatar
    if @user.update(user_params)
      redirect_to @user, notice: 'Avatar was successfully updated.'
    else
      @user.avatar.purge
      render :show, status: :unprocessable_entity, error: 'must be a JPEG or PNG'
    end
  end

  def clone
    @cloned_user = @user.deep_clone(include: :addresses)
    update_cloned_user_attributes
    if User.exists?(email: @cloned_user.email)
      flash[:alert] = 'User is already cloned.'
      redirect_to users_path and return
    end
    @user = @cloned_user
    render 'new_clone'
  end

  def create_clone
    @cloned_user = @user.deep_clone(include: :addresses)
    update_cloned_user_attributes
    @cloned_user.reset_password_token = generate_unique_token
    @user = @cloned_user
    respond_to do |format|
      if @user.save(validate: false)
        format.html { redirect_to root_path, notice: 'User was successfully cloned.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    user_id = params[:id].to_i
    response = Faraday.delete("https://gorest.co.in/public/v2/users/#{user_id}") do |req|
      req.headers['Authorization'] = 'Bearer 12b90432857c3ff89e83e2da58a8c74242408725e56e11fc02631972d88d971b'
      req.headers['Content-Type'] = 'application/json'
      req.options.timeout = 30
      req.options.open_timeout = 10
    end
    if response.success?
      flash[:notice] = 'User deleted successfully from the third-party system.'
      redirect_to users_path
    else
      error_message = JSON.parse(response.body)
      flash[:alert] = "Error deleting user: #{error_message}"
      redirect_to users_path
    end
  end

  # Use `deactivate` for soft delete
  def deactivate
    if @user.discard
      redirect_to users_path, notice: 'User was successfully deactivate.'
    else
      redirect_to users_path, alert: 'Failed to discard the user.'
    end
  end

  def activate
    if @user.undiscard
      redirect_to users_path, notice: 'User activated successfully.'
    else
      redirect_to users_path, alert: 'Failed to restore user.'
    end
  end

  def export_csv
    authorize current_user
    csv_data = CsvExportService.new(policy_scope(User).includes(addresses: %i[state city]).all).generate_csv
    respond_to do |format|
      format.csv do
        send_data csv_data, filename: "users-#{Date.today}.csv"
      end
    end
  end

  def export_csv_for_user
    csv_data = CsvExportService.new(@user).generate_csv_for_user
    respond_to do |format|
      format.csv { send_data csv_data, filename: "#{@user.first_name}-#{Date.today}.csv" }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = policy_scope(User).includes(:addresses).friendly.find(params[:id])
    return if @user.nil?

    @user = @user.decorate
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:name, :status, :email, :gender)
  end

  def user_not_found
    if !current_user.has_role? :student
      render file: Rails.root.join('public', '404.html'), status: :not_found, layout: false if @user.nil?
    else
      redirect_to users_path, alert: 'You are not authorized to access that page.'
    end
  end

  def update_cloned_user_attributes
    @cloned_user.first_name = "#{@user.first_name}_#{@user.id}"
    @cloned_user.last_name = "#{@user.last_name}_#{@user.id}"
    @cloned_user.email = "#{@user.id}_clone_#{@user.email}"
    return unless @user.avatar.attached?

    @cloned_user.avatar.attach(@user.avatar.blob)
  end

  def authorize_user
    authorize @user
  end

  def generate_unique_token
    loop do
      token = SecureRandom.hex(16)
      break token unless User.exists?(reset_password_token: token)
    end
  end

  def create_user_in_third_party_api(user_params)
    api_url = 'https://gorest.co.in/public/v2/users'

    begin
      response = Faraday.post(api_url) do |req|
        req.headers['Content-Type'] = 'application/json'
        req.headers['Authorization'] = 'Bearer 12b90432857c3ff89e83e2da58a8c74242408725e56e11fc02631972d88d971b'
        req.body = user_params.to_json
        req.options.timeout = 30
        req.options.open_timeout = 10
      end
      logger.info "API response status: #{response.status}"
      logger.info "API response body: #{response.body}"
    rescue Faraday::ConnectionFailed => e
      logger.error "API connection failed: #{e.message}"
      OpenStruct.new(success?: false, body: 'API connection failed')
    rescue Faraday::TimeoutError => e
      logger.error "API request timed out: #{e.message}"
      OpenStruct.new(success?: false, body: 'API request timed out')
    rescue StandardError => e
      logger.error "An unexpected error occurred: #{e.message}"
      OpenStruct.new(success?: false, body: 'Unexpected error')
    end

    response
  end
end
