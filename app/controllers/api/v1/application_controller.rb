module Api
  module V1
    class ApplicationController < ActionController::API
      include Pagy::Backend
      include JwtToken
      include Devise::Controllers::Helpers

      before_action :authenticate_user_from_token!

      def authenticate_user_from_token!
        token = request.headers['Authorization']&.split(' ')&.last

        if token.present?
          decoded_token = JwtToken.decode(token)
          if decoded_token.nil?
            render json: { errors: 'Invalid token' }, status: :unauthorized
          elsif decoded_token
            @current_user = User.find(decoded_token[:user_id])
          end
        else
          render json: { error: 'Token missing...' }, status: :unauthorized
        end
      rescue ActiveRecord::RecordNotFound => e
        render json: { errors: e.message }, status: :unauthorized
      rescue JWT::DecodeError => e
        render json: { errors: e.message }, status: :unauthorized
      end
    end
  end
end
