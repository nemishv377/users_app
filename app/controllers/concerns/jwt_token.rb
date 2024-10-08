require 'jwt'

module JwtToken
  extend ActiveSupport::Concern
  SECRET_KEY = Rails.application.credentials.secret_key_base.to_s
  def self.encode(payload)
    payload[:exp] = 24.hours.from_now.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new decoded
  rescue JWT::DecodeError
    nil
  end
end
