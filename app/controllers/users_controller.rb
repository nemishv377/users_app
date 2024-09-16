require 'csv'
class UsersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :user_not_found
  rescue_from Faraday::ConnectionFailed, Faraday::TimeoutError, with: :handle_api_error

  before_action :authenticate_user!
  before_action :set_user, only: %i[export_csv_for_user clone create_clone update_avatar activate deactivate]
  before_action :authorize_user, only: %i[clone create_clone update_avatar deactivate activate
                                          export_csv_for_user]

  # GET /users or /users.json
  def index
    @users = fetch_users_from_api
  end

  # GET /users/1 or /users/1.json
  def show
    @user = fetch_user_from_api(params[:id])
    nil unless @user
  end

  # GET /users/new
  def new
    @user = OpenStruct.new
  end

  # GET /users/1/edit
  def edit
    @user = fetch_user_from_api(params[:id])
    if @user
      @user = OpenStruct.new(@user)
    else
      flash[:alert] = "Failed to fetch user details: #{flash[:alert]}"
      redirect_to users_path
    end
  end

  # POST /users or /users.json
  def create
    response = create_user_in_third_party_api(user_params)
    handle_api_response(response, 'User created successfully in third-party system!', new_user_path)
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    response = update_user_in_third_party_api(params[:id], user_params)
    handle_api_response(response, 'User updated successfully in third-party system!', edit_user_path)
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
    response = delete_user_from_api(params[:id])
    handle_api_response(response, 'User deleted successfully from the third-party system.', users_path)
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

  def handle_api_response(response, success_message, redirect_path)
    if response.success?
      flash[:notice] = success_message
      redirect_to redirect_path
    else
      flash[:alert] = "Error: #{response.body}"
      redirect_to redirect_path
    end
  end

  def fetch_users_from_api
    response = Faraday.get('https://gorest.co.in/public/v2/users') do |req|
      req.headers['Authorization'] = 'Bearer 12b90432857c3ff89e83e2da58a8c74242408725e56e11fc02631972d88d971b'
      req.headers['Content-Type'] = 'application/json'
      req.options.timeout = 30
      req.options.open_timeout = 10
      req.params['page'] = 1
      req.params['per_page'] = 15
    end

    if response.success?
      JSON.parse(response.body)
    else
      flash[:alert] = "Failed to fetch users: #{response.status}"
      []
    end
  end

  def fetch_user_from_api(user_id)
    response = Faraday.get("https://gorest.co.in/public/v2/users/#{user_id}") do |req|
      req.headers['Authorization'] = 'Bearer 12b90432857c3ff89e83e2da58a8c74242408725e56e11fc02631972d88d971b'
      req.headers['Content-Type'] = 'application/json'
      req.options.timeout = 30
      req.options.open_timeout = 10
    end

    if response.success?
      JSON.parse(response.body)
    else
      flash[:alert] = "Failed to fetch user details: #{response.status}"
      nil
    end
  end

  def create_user_in_third_party_api(user_params)
    api_request(:post, 'https://gorest.co.in/public/v2/users', user_params)
  end

  def update_user_in_third_party_api(user_id, params)
    api_request(:put, "https://gorest.co.in/public/v2/users/#{user_id}", params)
  end

  def delete_user_from_api(user_id)
    api_request(:delete, "https://gorest.co.in/public/v2/users/#{user_id}")
  end

  def api_request(method, url, body = nil)
    Faraday.send(method, url) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = 'Bearer 12b90432857c3ff89e83e2da58a8c74242408725e56e11fc02631972d88d971b'
      req.body = body.to_json if body
      req.options.timeout = 30
      req.options.open_timeout = 10
    end
  rescue Faraday::ConnectionFailed, Faraday::TimeoutError, StandardError => e
    logger.error "API error: #{e.message}"
    OpenStruct.new(success?: false, body: e.message)
  end

  def handle_api_error(exception)
    logger.error "API connection error: #{exception.message}"
    render 'errors/connection_failed', status: :service_unavailable
  end
end
