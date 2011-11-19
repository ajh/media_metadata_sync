require 'musicbrainz'

module MediaMetadataSync
  module DB
    class MusicBrainz
      attr_accessor :user, :password

      def initialize(user, password)
        @user = user
        @password = password

        @brainz = ::MusicBrainz::Client.new(user, password)
      end

      def write(queue)
      end
    end
  end
end
