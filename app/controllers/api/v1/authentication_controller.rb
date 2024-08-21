module Api
  module V1
    class AuthenticationController < ApplicationController
      skip_before_action :authenticate_user
      # skip_before_action :verify_authenticity_token

      def login
        @user = User.find_by(email: params[:email])
        # puts "#{@user.id},#{@user.password}"
        if @user.valid_password?(params[:password])
          token = JwtToken.encode(user_id: @user.id)
          time = Time.now + 24.hours.to_i
          render json: { token:, exp: time.strftime('%m-%d-%Y %H:%M'),
                         user: @user }, status: :ok
        else
          render json: { error: 'unauthorized' }, status: :unauthorized
        end
      end
    end
  end
end
