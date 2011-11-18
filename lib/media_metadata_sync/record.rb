module MediaMetadataSync
  class Record < Struct.new(
    :album_rating,
    :location,
    :name,
    :rating)

    def initialize(options={})
      options.each do |k,v|
        setter = "#{k}="
        respond_to? setter or \
          raise ArgumentError.new("Unknown option #{k}")
        send setter, v
      end
    end
  end
end
