class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show edit update]
  load_and_authorize_resource

  # GET /users or /users.json
  def index
    @pagy, @users = pagy(User.includes(addresses: %i[state city]).all)
  end

  # GET /users/1 or /users/1.json
  def show
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

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy! || current_user.destroy!
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.includes(addresses: %i[state city]).find(params[:id]).decorate
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :gender, :avatar, hobbies: [],
                                                                                    addresses_attributes: %i[id plot_no society_name pincode state_id city_id default _destroy])
  end
end
