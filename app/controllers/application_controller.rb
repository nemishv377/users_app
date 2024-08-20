class ApplicationController < ActionController::Base
  include Pagy::Backend
  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from CanCan::AccessDenied do |_exception|
    redirect_to users_path, alert: 'You are not authorized to access that page.'
  end

  def render_404
    render file: Rails.root.join('public', '404.html'), status: :not_found, layout: false
  end
end
