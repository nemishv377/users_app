module Api
  module V1
    class ForgotPasswordService
      def initialize(email)
        @email = email.to_s.strip
      end

      def call
        return { message: 'Invalid email format.' } if invalid_email_format?

        user = User.find_by(email: @email)
        user&.send_reset_password_instructions
        { message: 'Mail has been sent to your email account.' }
      end

      private

      def invalid_email_format?
        !/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.match?(@email)
      end
    end
  end
end
