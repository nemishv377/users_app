class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]

  # GET /users or /users.json
  def index
    @users = User.all
   
  end

  # GET /users/1 or /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
    # @user.build_state
    # @user.build_city
  end

  # GET /users/1/edit
  def edit
  
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)
    # @state_id = user_params(state_id)
    # @para = user_params
    # puts "hello #{@para[:state_id][:state_id]}"
    # State.create(name: @para[:state_id][:state_id])
    # puts "state"
    # City.create(name: @para[:city_id][:city_id],state_id: @para[:state_id][:state_id])
    # puts "city"
    respond_to do |format|
      if @user.save
        format.html { redirect_to user_url(@user), notice: "User was successfully created." }
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
        format.html { redirect_to user_url(@user), notice: "User was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy!
    respond_to do |format|
      format.html { redirect_to users_url, notice: "User was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :gender, state_id: [:state_id], city_id: [:city_id],
      #  state_attributes: [:id, :name],:state_name,:city_name,
       hobbies: [])
    end
end
