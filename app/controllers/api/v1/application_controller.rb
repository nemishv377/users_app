module Api
  module V1
    class ApplicationController < ActionController::API
      include Pagy::Backend
      include JwtToken
      include Devise::Controllers::Helpers

      before_action :authenticate_user_from_token!

      rescue_from CanCan::AccessDenied do |_exception|
        redirect_to users_path, alert: 'You are not authorized to access that page.'
      end

      private

      def authenticate_user_from_token!
        token = request.headers['Authorization']&.split(' ')&.last

        if token.present?
          decoded_token = JwtToken.decode(token)
          if decoded_token.nil?
            render json: { errors: 'Invalid or missing token' }, status: :unauthorized
          elsif decoded_token
            @current_user = User.find(decoded_token[:user_id])
          end
        else
          render json: { error: 'Not Authorized' }, status: :unauthorized
        end
      rescue ActiveRecord::RecordNotFound => e
        render json: { errors: e.message }, status: :unauthorized
      rescue JWT::DecodeError => e
        render json: { errors: e.message }, status: :unauthorized
      end
    end
  end
end
