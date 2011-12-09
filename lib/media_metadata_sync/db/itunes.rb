require 'appscript'

module MediaMetadataSync
  module DB
    class ITunes
      def initialize
        @app = Appscript.app('iTunes')
      end

      # Here's a way to benchmark this method:
      #
      # time ruby -rrubygems -r /Users/ajh/devel/media_metadata_sync/lib/media_metadata_sync -e 'itunes = MediaMetadataSync::DB::ITunes.new; itunes.read(q = Queue.new); puts q.length'
      def read(queue)
        begin

          i = 1
          loop do
            track = @app.file_tracks[i]

            record = Record.new
            record.name = track.name.get
            record.rating = track.rating.get
            record.album_rating = track.album_rating.get

            queue << record

            i += 1
          end

        rescue Appscript::CommandError => e
          e.message =~ %r/Can't get reference/ or raise
        end

      ensure
        queue << 'alldone'
      end
    end
  end
end
