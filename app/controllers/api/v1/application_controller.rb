module Api
  module V1
    class ApplicationController < ActionController::API
      include Pagy::Backend
      include JwtToken
      include Devise::Controllers::Helpers

      before_action :authenticate_user
      before_action :authenticate_user_from_token!

      rescue_from CanCan::AccessDenied do |_exception|
        redirect_to users_path, alert: 'You are not authorized to access that page.'
      end

      private

      def authenticate_user
        header = request.headers['Authorization']
        header = header.split(' ').last if header
        begin
          @decoded = JwtToken.decode(header)
          if @decoded.nil?
            render json: { errors: 'Invalid or missing token' }, status: :unauthorized
          else
            @current_user = User.find(@decoded[:user_id])
          end
        rescue ActiveRecord::RecordNotFound => e
          render json: { errors: e.message }, status: :unauthorized
        rescue JWT::DecodeError => e
          render json: { errors: e.message }, status: :unauthorized
        end
      end

      def authenticate_user_from_token!
        token = request.headers['Authorization']&.split(' ')&.last
        Rails.logger.info "Authorization Header: #{request.headers['Authorization']}"
        Rails.logger.info "Token: #{token}"

        if token.present?
          decoded_token = JwtToken.decode(token)
          Rails.logger.info "Decoded Token: #{decoded_token.inspect}"
          @current_user = User.find(decoded_token[:user_id]) if decoded_token
        else
          render json: { error: 'Not Authorized' }, status: :unauthorized
        end

        Rails.logger.info "Current User: #{@current_user.inspect}"
        # render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
      end
    end
  end
end
