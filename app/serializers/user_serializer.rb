class UserSerializer
  include JSONAPI::Serializer
  attributes :first_name, :last_name, :email, :gender, :hobbies

  has_many :addresses, serializer: AddressSerializer
end
