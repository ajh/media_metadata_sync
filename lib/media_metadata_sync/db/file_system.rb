require 'active_support'
require 'shellwords'
#PLATFORM = RUBY_PLATFORM
#require 'tagfile'


module MediaMetadataSync
  module DB

    # Read and write metadata to files on a filesystem. For example:
    #
    # fs = MediaMetadataSync::DB::FileSystem.new '~/Music/Library'
    #
    # q = Queue.new
    # fs.read q # will add to the queue Records for each media file found inside ~/Music/Library
    #
    # q2 = ... # get a queue of Records from somewhere
    # fs.write q # write out any metadata changes to the files on disk
    class FileSystem
      attr_reader :root_path

      # Create a filesystem "database" with a root path of the given directory.
      def initialize(root_path)
        @root_path = Pathname.new root_path
      end

      def read(queue)
        Dir.glob @root_path.join("**/*.mp3") do |path|
          tags = TagFile::File.new path
          puts tags.inspect
        end
      end

      VENDOR = File.expand_path(File.dirname(__FILE__) + "/../../vendor").inspect
      PATH_BATCH_SIZE=1000

      # returns a hash of path => uuids pairs for each path passed. If a uuid
      # couldn't be determined, the uuid value will be nil
      def self.uuids_of_paths(paths)
        path_uuids = {}
        paths.each {|p| path_uuids[p.to_s] = nil}

        paths.collect{|p| Shellwords.escape p}.each_slice(PATH_BATCH_SIZE) do |ps|
          shell("#{VENDOR}/mb_track_id #{ps.join(' ')}").lines.each do |line|
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
end
