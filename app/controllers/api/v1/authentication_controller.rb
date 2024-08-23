module Api
  module V1
    class AuthenticationController < ApplicationController
      skip_before_action :authenticate_user_from_token!
      before_action :set_email, only: %i[reset_password_token forgot_password]
      before_action :set_password, only: %i[login edit_password]

      def signup
        if !params[:user].present?
          render json: { error: 'User data is required.' }, status: :unprocessable_entity
        else
          @user = User.new(user_params)
          if @user.save
            render @user, formats: [:json]
          else
            render json: @user.errors, status: :unprocessable_entity
          end
        end
      end

      def login
        @email = params[:email].to_s.strip

        if @email.blank? && @password.blank?
          render json: { message: 'Credential are required' }
        elsif @email.blank?
          render json: { message: 'Email is required' }
        elsif @password.blank?
          render json: { message: 'Password is required' }
        else
          @user = User.find_by(email: @email)

          if @user&.valid_password?(@password)
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

      def reset_password_token
        @user = User.find_by(email: @email)

        if !@user.nil?
          @user.send(:set_reset_password_token)
          @user.save(validate: false)
          UserMailer.reset_password_token(@user).deliver_later
          render json: { message: "Token is sended succesfully to #{@email}" },
                 status: :ok
        else
          render json: { error: 'Email not found' }, status: :not_found
        end
      end

      def edit_password
        reset_password_token = params[:reset_password_token]

        if @password.blank? && reset_password_token.blank?
          render json: { message: 'Token and password both are missing.' }
        elsif @password.blank?
          render json: { message: 'Password is required.' }
        elsif reset_password_token.blank?
          render json: { message: 'Token is required.' }
        else
          @user = User.find_by(reset_password_token:)

          if @user.nil?
            render json: { error: 'Invalid or expired token' }, status: :unprocessable_entity
          elsif @user&.update(password: @password, reset_password_token: nil)
            render json: { user: @user, message: 'Password successfully updated' }, status: :ok
          else
            render json: { error: 'Unable to update password' }, status: :unprocessable_entity
          end
        end
      end

      def forgot_password
        if invalid_email_format?
          render json: { message: 'Invalid email format.' }, status: :unprocessable_entity
        else
          @user = User.find_by(email: @email)
          @user&.send_reset_password_instructions
          render json: { message: 'Mail has been sent to your email account.' }
        end
      end

      private

      def user_params
        params.require(:user).permit(:first_name, :last_name, :email, :gender, :avatar, :password, hobbies: [],
                                                                                                   addresses_attributes: %i[id plot_no society_name pincode state_id city_id default _destroy])
      end

      def invalid_email_format?
        !/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.match?(@email)
      end

      def set_email
        @email = params[:email].to_s.strip
        return if @email.present?

        render json: { message: 'Email is required' }
      end

      def set_password
        @password = params[:password]
      end
    end
  end
end
