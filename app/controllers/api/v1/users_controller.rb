module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :authenticate_user_from_token!, only: [:create]
      before_action :set_user, only: %i[show update destroy]
      def index
        page = (params[:page].to_i.positive? ? params[:page].to_i : 1)
        @pagy, @users = pagy(User.includes(addresses: %i[state city]).all, page:)
        return unless @pagy.page > @pagy.pages || @pagy.page < 1

        @pagy, @users = pagy(User.includes(addresses: %i[state city]),
                             page: @pagy.pages)
        render 'api/v1/users/index', formats: [:json]
      end

      def create
        @user = User.new(user_params)
        if @user.save
          render 'api/v1/users/show', formats: [:json]
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      def show
        if current_user.has_role? :admin
          render 'api/v1/users/show', formats: [:json]
        elsif @user == current_user
          render 'api/v1/users/show', formats: [:json]
        else
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
        if @user.nil? && (current_user.has_role? :admin)
          render json: { error: 'User not found with this id.' }, status: :not_found
        elsif !(current_user.has_role? :admin) && !(@user == current_user)
          render json: { error: 'You are not authorized.' }, status: :not_found
        else
          @user
        end
      end
    end
  end
end
