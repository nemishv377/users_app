module Api
  module V1
    class ApplicationController < ActionController::API
      include Pagy::Backend
      include JwtToken
      before_action :authenticate_user

      rescue_from CanCan::AccessDenied do |_exception|
        redirect_to users_path, alert: 'You are not authorized to access that page.'
      end

      private

      def authenticate_user
        header = request.headers['Authorization']
        header = header.split(' ').last if header
        begin
          @decoded = JwtToken.decode(header)
          @current_user = User.find(@decoded[:user_id])
        rescue ActiveRecord::RecordNotFound => e
          render json: { errors: e.message }, status: :unauthorized
        rescue JWT::DecodeError => e
          render json: { errors: e.message }, status: :unauthorized
        end
      end
    end
  end
end
