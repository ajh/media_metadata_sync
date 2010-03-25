#!/usr/bin/ruby

require 'rubygems'
require 'itunes'
require 'mb'
require 'active_support'

def shellescape(str)
   # An empty argument will be skipped, so return empty
   # quotes.
  return "''" if str.empty?

  str = str.dup

  # Process as a single byte sequence because not all
  # shell implementations are multibyte aware.
  str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1")

  # A LF cannot be escaped with a backslash because a
  # backslash + LF combo is regarded as line continuation
  # and simply ignored.
  str.gsub!(/\n/, "'\n'")

  return str
end

# return an array with the first element a pathname and
# the second element the uuid
def parse_mb_track_id_line(line)
  regexp = %r/^(.*) \[http:\/\/musicbrainz.org\] (.*)/
  if match = regexp.match(line)
    [Pathname.new(match[1]), match[2].chomp]
  else
    []
  end
end
   
# pull ratings from itunes
ratings = ITunes.track_ratings

# pull mb uuid from mp3 files
escaped_files = ratings.keys.collect {|p| shellescape p.to_s}

escaped_files.each_slice(1000) do |files|
  %x(./mb_track_id #{files.join(' ')}).each do |line|
    path, uuid = parse_mb_track_id_line(line)

    if path and uuid
      ratings[path][:uuid] = uuid
    end
  end
end

# upload ratings to musicbrainz
ratings.each do |path, info|
  begin
    track = MB::Track.new info[:uuid]
  rescue ArgumentError
  end

  track or next

  track.rating = info[:rating]
  puts "saving #{track.inspect}"
  begin
    track.save
  rescue MusicBrainz::Webservice::RequestError => e
    warn e.inspect
  end

  sleep 1 # be nice if MB took care of this
end
