class AuthorizeUser
  def initialize(current_user, user, role)
    @current_user = current_user
    @user = user
    @role = role
  end

  def call
    return true if @current_user.has_role?(@role)

    true if @user == @current_user
  end
end
