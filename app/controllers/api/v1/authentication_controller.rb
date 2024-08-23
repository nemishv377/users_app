module Api
  module V1
    class AuthenticationController < ApplicationController
      skip_before_action :authenticate_user_from_token!

      def signup
        @user = User.new(user_params)
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
          @user.send(:set_reset_password_token)
          @user.save(validate: false)
          UserMailer.reset_password_token(@user).deliver_later
          render json: { message: "Token is sended succesfully to #{@user.email}" },
                 status: :ok
        else
          render json: { error: 'Email not found' }, status: :not_found
        end
      end

      def edit_password
        @user = User.find_by(reset_password_token: params[:reset_password_token])

        if @user.nil?
          render json: { error: 'Invalid or expired token' }, status: :unprocessable_entity
        elsif @user&.update(password: params[:password], reset_password_token: nil)
          render json: { user: @user, message: 'Password successfully updated' }, status: :ok
        else
          render json: { error: 'Unable to update password' }, status: :unprocessable_entity
        end
      end

      def forgot_password
        @user = User.find_by(email: params[:email])
        @user&.send_reset_password_instructions
        render json: { message: 'Mail has sent to your mail account.' }
      end

      private

      def user_params
        params.require(:user).permit(:first_name, :last_name, :email, :gender, :avatar, :password, hobbies: [],
                                                                                                   addresses_attributes: %i[id plot_no society_name pincode state_id city_id default _destroy])
      end
    end
  end
end
