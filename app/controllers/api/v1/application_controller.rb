module Api
  module V1
    class ApplicationController < ActionController::API
      include Pagy::Backend
      rescue_from CanCan::AccessDenied do |_exception|
        redirect_to users_path, alert: 'You are not authorized to access that page.'
      end
    end
  end
end
