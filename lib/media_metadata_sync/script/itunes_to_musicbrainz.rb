require 'active_support'

module Script
  module ItunesToMusicbrainz
    def self.run
      # pull ratings from itunes
      ratings = Source::ITunes.track_ratings

      # pull mb uuid from mp3 files
      paths = ratings.keys.collect(&:to_s)
      uuids = Source::FileSystem.uuids_of_paths paths

      lookup = Hash.new paths.zip(uuids)

      ratings.each do |p, info|
        info[:uuid] = lookup[p.to_s]
      end

      # upload ratings to musicbrainz
      ratings.each do |path, info|
        begin
          track = Source::MB::Track.new info[:uuid]
        rescue ArgumentError
        end

        track or next

        track.rating = info[:rating]
        puts "saving #{track.inspect}"
        begin
          track.save
        rescue MusicBrainz::Webservice::RequestError => e # hack, need to wrap this error or the abstraction leaks
          warn e.inspect
        end

        sleep 1 # be nice if MB took care of this
      end
    end
  end
end
