class ApplicationController < ActionController::Base
  include Pagy::Backend
  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :email, :gender, :avatar,
                                                       { hobbies: [],
                                                         addresses_attributes: %i[id plot_no society_name pincode
                                                                                  state_id city_id default _destroy] }])

    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :email, :gender, :avatar,
                                                              { hobbies: [],
                                                                addresses_attributes: %i[id plot_no society_name pincode
                                                                                         state_id city_id default _destroy] }])
  end
end
