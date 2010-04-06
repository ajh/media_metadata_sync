require 'active_support'

module Source
  module FileSystem
    VENDOR = File.expand_path(File.dirname(__FILE__) + "/../../vendor").inspect

    # return a list of uuids given a list of filenames. If a file doesn't have
    # a uuid, a null will be in the returned list. The order of the returned
    # list will match the order of the passed files.
    def self.uuids_of_paths(paths)
      paths = paths.collect {|p| shellescape p.to_s}

      uuids = []
      paths.each_slice(1000) do |ps|
        %x(#{VENDOR}/mb_track_id #{ps.join(' ')}).each do |line|
          path, uuid = parse_mb_track_id_line(line)
          uuids << uuid
        end
      end

      uuids
    end

    private

      def self.shellescape(str)
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
      def self.parse_mb_track_id_line(line)
        regexp = %r/^(.*) \[http:\/\/musicbrainz.org\] (.*)/
        if match = regexp.match(line)
          [Pathname.new(match[1]), match[2].chomp]
        else
          []
        end
      end
  end
end
