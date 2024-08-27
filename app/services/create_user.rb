class CreateUser
  def initialize(user_params)
    @user_params = user_params
  end

  def call
    @user = User.new(@user_params)
    @user.password = SecureRandom.hex(5)
    @user
  end
end
