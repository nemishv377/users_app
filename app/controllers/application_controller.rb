class ApplicationController < ActionController::Base
  include Pagy::Backend
  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to users_path, alert: 'You are not authorized to access that page.'
  end
end
