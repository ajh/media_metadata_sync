require 'appscript'
require 'thread'

module MediaMetadataSync
  module Source
    module ITunes

      # Reads the iTunes database and writes records to the Queue. Returns true
      # is success, false if error.
      def self.read(queue)
        app = Appscript.app('iTunes')
        records = {}

        # this assumes the order of track remains the same
        # between applescript calls
        %w(album_rating rating location).each do |attr|
          app.file_tracks.send(attr).get.each_with_index do |val, i|
            (records[i] ||= Record.new).send "#{attr}=", val
          end
        end

        records.each { |k,v| queue << v }
      end

      # Return a hash of track ratings with the following
      # structure: {Pathname => {'album_rating' => 4, 'rating' =>
      # 1}}
      def self.track_ratings
        app = Appscript.app('iTunes')

        info = {}

        # this assumes the order of track remains the same
        # between applescript calls
        %w(album_rating rating location).each do |attr|
          app.file_tracks.send(attr).get.each_with_index do |val, i|
            (info[i] ||= {})[attr.to_sym] = val
          end
        end

        info.values.inject({}) do |memo, info| 
          memo[Pathname.new info.delete(:location).path] = {
            :rating => info[:rating] / 20.0,
            :album_rating => info[:album_rating] / 20.0,
          }

          memo
        end
      end
    end
  end
end
