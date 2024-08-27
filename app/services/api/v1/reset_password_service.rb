module Api
  module V1
    class ResetPasswordService
      def initialize(email)
        @email = email.to_s.strip
      end

      def call
        user = User.find_by(email: @email)
        return { error: 'Email not found' } if user.nil?

        user.send(:set_reset_password_token)
        user.save(validate: false)
        UserMailer.reset_password_token(user).deliver_later
        { message: "Token is sent successfully to #{@email}" }
      end
    end
  end
end
