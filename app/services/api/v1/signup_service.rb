module Api
  module V1
    class SignupService
      def initialize(user_params)
        @user_params = user_params
      end

      def call
        user = User.new(@user_params)
        if user.save
          { user: }
        else
          { error: user.errors }
        end
      end
    end
  end
end
