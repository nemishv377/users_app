module Api
  module V1
    class UsersController < ApplicationController
      before_action :authorize_admin!, only: [:create]
      before_action :set_user, only: %i[show update destroy]
      before_action :check_user_params, only: %i[create update]
      def index
        page = (params[:page].to_i.positive? ? params[:page].to_i : 1)
        @pagy, @users = pagy(User.includes(addresses: %i[state city]).all, page:)
        return unless @pagy.page > @pagy.pages || @pagy.page < 1

        @pagy, @users = pagy(User.includes(addresses: %i[state city]),
                             page: @pagy.pages)
        render 'api/v1/users/index', formats: [:json]
      end

      def create
        # @user = User.new(user_params)
        # @user.password = SecureRandom.hex(5)
        @user = ::CreateUser.new(user_params).call
        if @user.save
          render 'api/v1/users/show', formats: [:json]
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      def show
        if @user.nil? && (current_user.has_role? :admin)
          render json: { error: 'User not found with this id.' }, status: :not_found
        # elsif (current_user.has_role? :admin) || (@user == current_user)
        elsif AuthorizeUser.new(current_user, @user, :admin).call
          render 'api/v1/users/show', formats: [:json]
        elsif !(current_user.has_role? :admin) && !(@user == current_user)
          render json: { error: 'You are not authorized.' }, status: :not_found
        end
      end

      def update
        if @user.update(user_params)
          render 'api/v1/users/show', formats: [:json]
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      # DELETE /users/1 or /users/1.json
      def destroy
        @user.destroy!
        render json: { notice: 'User was successfully destroyed.' }
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

        render json: { error: 'User data is missing' }, status: :unprocessable_entity
      end
    end
  end
end
