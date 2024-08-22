module Api
  module V1
    class AuthenticationController < ApplicationController
      skip_before_action :authenticate_user_from_token!, only: %i[login reset_password_token edit_password]
      before_action :authorize_admin!, only: [:signup]

      def signup
        @user = User.new(user_params)
        @user.password = SecureRandom.hex(5)
        if @user.save
          render @user, formats: [:json]
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      def login
        @user = User.find_by(email: params[:email])

        if @user&.valid_password?(params[:password])
          token = JwtToken.encode(user_id: @user.id)
          exp_time = 24.hours.from_now

          render json: {
            token:,
            exp: exp_time.strftime('%m-%d-%Y %H:%M'),
            user: @user
          }, status: :ok
        else
          render json: { error: 'Invalid email or password.' }, status: :unauthorized
        end
      end

      def reset_password_token
        @user = User.find_by(email: params[:email])
        if !@user.nil?
          # Generate a password reset token
          token = @user.send(:set_reset_password_token) # Private method to set the token
          @user.update(reset_password_token: token)
          # Save the user record to ensure the token is persisted
          @user.save(validate: false)

          render json: { user: @user, reset_password_token: @user.reset_password_token, reset_password_tokenn: token },
                 status: :ok
        else
          render json: { error: 'Email not found' }, status: :not_found
        end
      end

      def edit_password
        @user = User.find_by(reset_password_token: params[:reset_password_token])
        if @user
          if @user.update(password: params[:password], reset_password_token: nil)
            render json: { user: @user, message: 'Password successfully updated' }, status: :ok
          else
            render json: { error: 'Unable to update password' }, status: :unprocessable_entity
          end
        else
          render json: { error: 'Invalid or expired token' }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:first_name, :last_name, :email, :gender, :avatar, hobbies: [],
                                                                                        addresses_attributes: %i[id plot_no society_name pincode state_id city_id default _destroy])
      end

      def authorize_admin!
        render json: { error: 'Not Authorized' }, status: :unauthorized unless @current_user.has_role? :admin
      end
    end
  end
end
