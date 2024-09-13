class SendWelcomeEmailJob
  include Sidekiq::Job

  def perform(user_id)
    @user = User.find(user_id)
    UserMailer.welcome_email(@user).deliver_now
  end
end
