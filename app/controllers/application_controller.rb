class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  rescue_from ActionController::RoutingError, with: :render_404

  # rescue_from CanCan::AccessDenied do |_exception|
  #   redirect_to users_path, alert: 'You are not authorized to access that page.'
  # end

  def render_404
    render file: Rails.root.join('public', '404.html'), status: :not_found, layout: false
  end

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_to(request.referer || root_path)
  end
end
