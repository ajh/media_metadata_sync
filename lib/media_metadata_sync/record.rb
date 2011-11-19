module MediaMetadataSync
  class Record < Struct.new(
    :album_rating,
    :location,
    :music_brainz_id,
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

    def to_hash
      members.inject({}) {|memo, k| memo[k] = send(k); memo}
    end
  end
end
