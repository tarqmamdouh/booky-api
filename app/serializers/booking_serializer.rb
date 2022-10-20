class BookingSerializer
  include JSONAPI::Serializer
  attributes :id, :name, :description, :start, :end
end
