class UserMailer < ApplicationMailer
  default from: 'nemishv.tagline@gmail.com'
  def welcome_email(user)
    @user = user.decorate
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
    puts 'mail sended'
  end

  def reset_password_token(user)
    @user = user.decorate
    mail(to: @user.email, subject: 'Reset password token')
  end
end
