module Api
  module V1
    class UsersController < ApplicationController
      before_action :authorize_admin!, only: [:create]
      before_action :set_user, only: %i[show update destroy]
      before_action :check_user_params, only: %i[create update]
      before_action :authorize_user, only: %i[update destroy]
      def index
        @pagy, @users = pagy(User.includes(addresses: %i[state city]))
        # render 'api/v1/users/index', formats: [:json]
        serialized_users = UserSerializer.new(@users, include: [:addresses]).serializable_hash
        pagination_metadata = {
          current_page: @pagy.page,
          next_page: @pagy.next,
          prev_page: @pagy.prev,
          total_pages: @pagy.pages,
          items_count: @pagy.count
        }

        # Combine both into one response
        response = {
          pagination: pagination_metadata,
          users: serialized_users
        }

        render json: response.to_json
        # render json: UserSerializer.new(@users, include: [:addresses]).serializable_hash.to_json
      end

      def create
        @user = ::CreateUser.new(user_params).call
        if @user.save
          # render 'api/v1/users/show', formats: [:json]
          render json: UserSerializer.new(@user, { include: [:addresses] }).serializable_hash.to_json, status: :ok
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      def show
        if @user.nil? && (current_user.has_role? :admin)
          render json: { error: 'User not found with this id.' }, status: :not_found
        # elsif (current_user.has_role? :admin) || (@user == current_user)
        elsif AuthorizeUser.new(current_user, @user, :admin).call
          # render 'api/v1/users/show', formats: [:json]
          render json: UserSerializer.new(@user,  { include: [:addresses] }).serializable_hash.to_json, status: :ok
        elsif !(current_user.has_role? :admin) && !(@user == current_user)
          render json: { error: 'You are not authorized.' }, status: :not_found
        end
      end

      def update
        if @user.update(user_params)
          # render 'api/v1/users/show', formats: [:json]
          render json: UserSerializer.new(@user, { include: [:addresses] }).serializable_hash.to_json, status: :ok
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      # DELETE /users/1 or /users/1.json
      def destroy
        if @user.destroy!
          render json: { notice: 'User was successfully destroyed.' }, status: :ok
        else
          render json: { error: 'Failed to destroy the user.' }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:first_name, :last_name, :email, :gender, :avatar, :password, :password_confirmation, hobbies: [],
                                                                                                                           addresses_attributes: %i[id plot_no society_name pincode state_id city_id default _destroy])
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_user
        @user = User.includes(addresses: %i[state city]).find_by(id: params[:id])
      end

      def authorize_admin!
        render json: { error: 'Not Authorized' }, status: :unauthorized unless @current_user.has_role? :admin
      end

      def check_user_params
        return if params[:user].present?

        render json: { message: 'User data is required.' }, status: :unprocessable_entity
      end

      def authorize_user
        if @user.nil?
          error_message = current_user.has_role?(:admin) ? 'User not found with this id.' : 'You are not authorized.'
          render json: { error: error_message }, status: :not_found
        elsif !current_user.has_role?(:admin) && @user != current_user
          render json: { error: 'You are not authorized.' }, status: :forbidden
        end
      end
    end
  end
end
