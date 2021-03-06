require 'appscript'

module MediaMetadataSync
  module DB
    class ITunes
      def initialize
        @app = Appscript.app('iTunes')
      end

      # Todo:
      # * populate music_brainz_id and other ids if possible, maybe even from files on disk.
      def read(queue)
        # Here's a way to benchmark this method:
        #
        # time ruby -rrubygems -r /Users/ajh/devel/media_metadata_sync/lib/media_metadata_sync -e 'itunes = MediaMetadataSync::DB::ITunes.new; itunes.read(q = Queue.new); puts q.length'
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

      # Todo:
      # * conflict resolution based on dates. Don't update things that are fresher in itunes than the queue.
      def write(queue)
        while (record = queue.shift) != 'alldone' do
          track = find_track_by_itunes_id record.itunes_id
          track or next

          comment = track.comment.get
          dates = comment.present? ? YAML.load(comment) : {}
          dirty = false

          if record.rated_at && (!dates['rated_at'] || dates['rated_at'] < record.rated_at)
            track.rating.set record.rating
            dates['rated_at'] = record.rated_at
            dirty = true
          end

          track.comment.set YAML.dump(dates) if dirty
        end
      end

      private

      # A stubbing target that helps isolate the tests from appscript stuff
      def find_track_by_itunes_id(id)
        @app.file_tracks[Appscript.its.persistent_ID.eq(id)].first
      end
    end
  end
end
