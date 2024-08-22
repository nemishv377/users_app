module Api
  module V1
    class AuthenticationController < ApplicationController
      skip_before_action :authenticate_user_from_token!

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
    end
  end
end
