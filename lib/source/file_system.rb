require 'active_support'

module Source
  module FileSystem
    VENDOR = File.expand_path(File.dirname(__FILE__) + "/../../vendor").inspect
    PATH_BATCH_SIZE=1000

    # returns a hash of path => uuids pairs for each path passed. If a uuid
    # couldn't be determined, the uuid value will be nil
    def self.uuids_of_paths(paths)
      path_uuids = {}
      paths.each {|p| path_uuids[p.to_s] = nil}

      paths.collect{|p| shellescape p}.each_slice(PATH_BATCH_SIZE) do |ps|
        shell("#{VENDOR}/mb_track_id #{ps.join(' ')}").each do |line|
          path, uuid = parse_mb_track_id_line(line)
          if path_uuids.key?(path.to_s)
            path_uuids[path.to_s] = uuid
          end
        end
      end

      path_uuids
    end

    private

      def self.shellescape(str)
        str.present? or return "''"

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

      # return an array with the first element a pathname and the second
      # element the uuid
      def self.parse_mb_track_id_line(line)
        regexp = %r/^(.*) \[http:\/\/musicbrainz.org\] (.*)/
        if match = regexp.match(line)
          [Pathname.new(match[1]), match[2].chomp]
        else
          []
        end
      end

      # wrapper around Kernel#` to make testing easier
      def self.shell(command)
        %x"#{command}"
      end
  end
end
