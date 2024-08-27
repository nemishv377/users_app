module Api
  module V1
    class AuthenticationController < ApplicationController
      skip_before_action :authenticate_user_from_token!
      before_action :set_email, only: %i[reset_password_token forgot_password]
      before_action :set_password, only: %i[login edit_password]

      def signup
        if !params[:user].present?
          render json: { message: 'User data is required.' }, status: :unprocessable_entity
        else
          service = Api::V1::SignupService.new(user_params)
          result = service.call
          if result[:error]
            render json: result[:error], status: :unprocessable_entity
          else
            render result[:user], formats: [:json]
          end
        end
      end

      def login
        @email = params[:email].to_s.strip
        service = Api::V1::LoginService.new(@email, @password)
        result = service.call
        if result[:error]
          render json: result[:error], status: :unauthorized
        else
          render json: result, status: :ok
        end
      end

      def reset_password_token
        service = Api::V1::ResetPasswordService.new(@email)
        result = service.call
        if result[:error]
          render json: result[:error], status: :not_found
        else
          render json: result, status: :ok
        end
      end

      def edit_password
        service = Api::V1::EditPasswordService.new(params[:reset_password_token], @password)
        result = service.call
        if result[:error]
          render json: result[:error], status: :unprocessable_entity
        else
          render json: result, status: :ok
        end
      end

      def forgot_password
        service = Api::V1::ForgotPasswordService.new(@email)
        result = service.call
        if result[:error]
          render json: result[:error], status: :unprocessable_entity
        else
          render json: result
        end
      end

      private

      def user_params
        params.require(:user).permit(:first_name, :last_name, :email, :gender, :avatar, :password, hobbies: [],
                                                                                                   addresses_attributes: %i[id plot_no society_name pincode state_id city_id default _destroy])
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
