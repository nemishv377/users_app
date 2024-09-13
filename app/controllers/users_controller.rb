require 'csv'
class UsersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :user_not_found

  before_action :authenticate_user!
  before_action :set_user,
                only: %i[edit update destroy export_csv_for_user clone create_clone update_avatar activate deactivate]
  before_action :authorize_user,
                only: %i[edit update destroy clone create_clone update_avatar deactivate activate
                         export_csv_for_user]

  # load_and_authorize_resource

  # GET /users or /users.json
  def index
    page = (params[:page].to_i > 0 ? params[:page].to_i : 1)
    @pagy, @users = pagy(User.includes(addresses: %i[state city]).all, page:)
    return unless @pagy.page > @pagy.pages || @pagy.page < 1

    @pagy, @users = pagy(User.includes(addresses: %i[state city]), page: @pagy.pages)
  end

  # GET /users/1 or /users/1.json
  def show
    @user = User.includes(addresses: %i[state city]).friendly.find(params[:id])
    authorize @user
    MyFirstJob.perform_async(@user.id)
    @user = @user.decorate
    @default_address = @user.addresses.default.first
  end

  # GET /users/new
  def new
    authorize current_user
    @user = User.new
    @user.addresses.build
  end

  # GET /users/1/edit
  def edit
    @user.build_address if @user.addresses.nil?
  end

  # POST /users or /users.json
  def create
    authorize current_user
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
    @user.destroy!
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
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
    @user = User.includes(:addresses).friendly.find(params[:id])
    return if @user.nil?

    @user = @user.decorate
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :gender, :avatar, :password, :password_confirmation, hobbies: [],
                                                                                                                       addresses_attributes: %i[id plot_no society_name pincode state_id city_id default _destroy])
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
end
