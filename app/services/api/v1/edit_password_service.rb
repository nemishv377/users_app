module Api
  module V1
    class EditPasswordService < BusinessProcess::Base
      needs :reset_password_token
      needs :password

      def call
        return { message: 'Token and password both are missing.' } if password.blank? && reset_password_token.blank?
        return { message: 'Password is required.' } if password.blank?
        return { message: 'Token is required.' } if reset_password_token.blank?

        user = User.find_by(reset_password_token:)
        return { error: 'Invalid or expired token' } if user.nil?

        if user.update(password:, reset_password_token: nil)
          { message: 'Password successfully updated',
            user: UserSerializer.new(user, { include: [:addresses] }).serializable_hash }
        else
          { error: 'Unable to update password' }
        end
      end
    end
  end
end
