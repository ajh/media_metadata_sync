require 'rbrainz'

module Source
  # my MusicBrainz Wrapper
  module MB
    class << self; attr_accessor :ws, :query; end
    @ws = MusicBrainz::Webservice::Webservice.new :username => 'shngn1', :password => 'uv@Q*kc8'
    @query = MusicBrainz::Webservice::Query.new @ws, :client_id => "Shngn1's rating sync tool"

    class Track
      def initialize(mbid)
        mbid.present? or raise ArgumentError.new('mbid is required')

        @mbid = MusicBrainz::Model::MBID.new mbid, :track
        @attributes = {}
      end

      def rating
        @attributes[:rating] ||= MB.query.get_user_rating(@mbid).value
      end

      def rating=(rating)
        @attributes[:rating] = rating.to_f
      end

      def save
        MB.query.submit_user_rating @mbid, @attributes[:rating]

        true
      end

      def reload
        @attributes.clear
      end

      def inspect
        "#<#{self.class.to_s} mbid:#{@mbid.inspect} attributes:#{@attributes.inspect}>"
      end
    end
  end
end
