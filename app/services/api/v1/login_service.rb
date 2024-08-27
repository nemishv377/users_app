module Api
  module V1
    class LoginService < BusinessProcess::Base
      needs :email
      needs :password

      def call
        return { message: 'Credentials are required' } if email.blank? && password.blank?
        return { message: 'Email is required' } if email.blank?
        return { message: 'Password is required' } if password.blank?

        user = User.find_by(email:)
        if user&.valid_password?(password)
          token = JwtToken.encode(user_id: user.id)
          exp_time = 24.hours.from_now
          {
            token:,
            exp: exp_time.strftime('%m-%d-%Y %H:%M'),
            user:
          }
        else
          { error: 'Invalid email or password.' }
        end
      end
    end
  end
end
