require 'appscript'

module MediaMetadataSync
  module DB
    class ITunes
      def initialize
        @app = Appscript.app('iTunes')
      end

      def read(queue)
        records = {}

        # This assumes the order of track remains the same between applescript
        # calls. It's also slow. Each field requires a separate traversal of
        # the library. With 4 fields, thats O(4n) where n is the number of
        # tracks in the library.
        %w(album_rating rating location name).each do |attr|
          @app.file_tracks.send(attr).get.each_with_index do |val, i|
            (records[i] ||= Record.new).send "#{attr}=", val
          end
        end

        records.each { |k,v| queue << v }

        queue << 'alldone'
      end
    end
  end
end
