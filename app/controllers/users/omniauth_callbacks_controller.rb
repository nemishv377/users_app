# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_oauth_callback(:google)
  end

  def github
    handle_oauth_callback(:github)
  end

  def linkedin
    handle_oauth_callback(:linkedin)
  end

  def facebook
    handle_oauth_callback(:facebook)
  end

  def failure
    redirect_to root_path, alert: 'Authentication failed, please try again.'
  end

  private

  def handle_oauth_callback(provider)
    @user = User.send("from_#{provider}", auth)

    if @user.present? && @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider.capitalize) if is_navigational_format?
    else
      session["devise.#{provider}_data"] = auth.except(:extra)
      if provider == :google
        flash[:alert] =
          I18n.t('devise.omniauth_callbacks.failure', kind: provider.capitalize,
                                                      reason: "#{auth.info.email} is not authorized.")
      end
      redirect_to new_user_registration_url
    end
  end

  def auth
    @auth ||= request.env['omniauth.auth']
  end

  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/heartcombo/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
