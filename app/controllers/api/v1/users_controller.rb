module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: %i[show update destroy]
      def index
        @pagy, @users = pagy(User.includes(addresses: %i[state city]).all)
        render 'api/v1/users/index', formats: [:json]
      end

      def show
        render 'api/v1/users/show', formats: [:json]
      end

      def update
        respond_to do |format|
          if @user.update(user_params)
            format.json do
              render :show, status: :ok,
                            location: api_v1_user_url(@user, include: { addresses: { include: %i[state city] } })
            end
          else
            format.json { render json: @user.errors, status: :unprocessable_entity }
          end
        end
      end

      # DELETE /users/1 or /users/1.json
      def destroy
        @user.destroy!
        head :no_content
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_user
        @user = User.includes(addresses: %i[state city]).find_by(id: params[:id])
        return unless @user.nil?

        render json: { error: 'User not found with this id.' }, status: :not_found
      end
    end
  end
end
