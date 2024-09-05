require 'csv'
class UsersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :user_not_found

  before_action :authenticate_user!
  before_action :set_user, only: %i[show edit update destroy export_csv_for_user clone]
  load_and_authorize_resource

  # GET /users or /users.json
  def index
    page = (params[:page].to_i > 0 ? params[:page].to_i : 1)
    @pagy, @users = pagy(User.includes(addresses: %i[state city]).all, page:)
    return unless @pagy.page > @pagy.pages || @pagy.page < 1

    @pagy, @users = pagy(User.includes(addresses: %i[state city]), page: @pagy.pages)
  end

  # GET /users/1 or /users/1.json
  def show
    @cloned_user = @user.deep_clone(include: :addresses)
    @default_address = @user.addresses.default.first
  end

  # GET /users/new
  def new
    @user = User.new
    @user.addresses.build
  end

  # GET /users/1/edit
  def edit
    @user.build_address if @user.addresses.nil?
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        format.html { redirect_to user_url(@user), notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to user_url(@user), notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def clone
    set_cloned_user(@user)
    if @cloned_user.save(validate: false)
      redirect_to root_path, notice: 'User successfully cloned.'
    else
      redirect_to root_path, alert: 'Failed to clone user.'
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy!
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def export_csv
    csv_data = CsvExportService.new(User.includes(addresses: %i[state city]).all).generate_csv
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
    @user = User.includes(addresses: %i[state city]).find_by(id: params[:id])
    return if @user.nil?

    @user = @user.decorate
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :gender, :avatar, hobbies: [],
                                                                                    addresses_attributes: %i[id plot_no society_name pincode state_id city_id default _destroy])
  end

  def user_not_found
    if !current_user.has_role? :student
      render file: Rails.root.join('public', '404.html'), status: :not_found, layout: false if @user.nil?
    else
      redirect_to users_path, alert: 'You are not authorized to access that page.'
    end
  end

  def set_cloned_user(user)
    @cloned_user = user.deep_clone(include: :addresses)
    @cloned_user.first_name = user.first_name + '_' + user.id.to_s
    @cloned_user.last_name = user.last_name + '_' + user.id.to_s
  end
end
