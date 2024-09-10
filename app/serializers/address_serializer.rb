class AddressSerializer
  include JSONAPI::Serializer

  attributes :plot_no, :society_name, :pincode
  attribute :state do |address|
    address.state.name
  end

  attribute :city do |address|
    address.city.name
  end
end
