class UserSerializer
  include JSONAPI::Serializer
  attributes :first_name, :last_name, :email, :gender, :hobbies

  attribute :avatar_url do |user|
    Rails.application.routes.url_helpers.url_for(user.avatar) if user.avatar.attached?
  end

  has_many :addresses, serializer: AddressSerializer
end
