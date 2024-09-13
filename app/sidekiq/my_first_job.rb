class MyFirstJob
  include Sidekiq::Job

  def perform(user)
    @user = User.find(user)
    puts "I am #{@user.first_name}."
  end
end
