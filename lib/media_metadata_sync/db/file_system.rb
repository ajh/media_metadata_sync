require 'shellwords'

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

      EYED3_CMD="eyeD3".freeze # can add a custom path here
      EYED3_MAX_PROCS="+0" # how many processes to use for eyed3 commands

      # Create a filesystem "database" with a root path of the given directory.
      def initialize(root_path)
        @root_path = Pathname.new root_path
      end

      # Note: Requires eyeD3 and parallel which are both available to mac ports
      def read(queue)
        cmd = <<-CMD
find #{Shellwords.shellescape @root_path.to_s} -iname '*.mp3' -print0 | parallel --null --max-args 1 --max-procs #{EYED3_MAX_PROCS} sh -c \\"echo ===== {} =====\\; #{EYED3_CMD} --no-color {}\\"
        CMD
        IO.popen(cmd) do |io|
          parser = EyeD3Parser.new

          while line = io.gets
            record = parser.readline line
            queue << record if record
          end
        end
        queue << 'alldone'
      end

      def write(queue)
        while (record = queue.pop) != 'alldone'
          record.location.to_s =~ /^#{Regexp.escape @root_path.to_s}/ or next

          cmd = "#{EYED3_CMD} --no-color --strict %s #{Shellwords.shellescape record.location.to_s}"
          options = []
          if record.rating && record.rated_at
           options << "--set-user-text-frame mms_rating:\"#{record.rating} #{record.rated_at.iso8601}\""
          end
          if record.album_rating && record.album_rated_at
           options << "--set-user-text-frame mms_album_rating:\"#{record.album_rating} #{record.album_rated_at.iso8601}\""
          end

          if options.any?
            cmd = cmd % options.join(" ")
            system cmd
          end
        end
      end

      private

      # Make stubbing in tests easier
      def system(*args, &block)
        Kernel.system *args, &block
      end

      class EyeD3Parser
        def initialize
          @record = @last_field = nil
        end

        # Pass input lines to be parsed. Returns a newly completed record, or
        # nil.
        #
        # The parser maintains internal state of partially parsed records.
        def readline(line)
          if line =~ /^===== (.*) =====$/
            flush_last_field
            last_record = @record
            @record = Record.new :location => Pathname.new($1)
            return last_record

          elsif line =~ /^title: (.*)\t\t/
            flush_last_field
            @record[:name] = $1

          elsif line =~ /^Unique File ID: \[http:\/\/musicbrainz\.org\]\s*$/
            flush_last_field
            @last_field = {:name => :music_brainz_id}

          elsif line =~ /^Unique File ID: \[http:\/\/musicbrainz\.org\] (.+)$/
            flush_last_field
            @record[:music_brainz_id] = $1

          elsif line =~ /^UserTextFrame: \[Description: mms_(\w+)\]$/
            flush_last_field
            @last_field = {:name => $1.to_s} if Record.members.map(&:to_s).include? $1

          elsif @last_field
            @last_field[:value] ||= String.new
            @last_field[:value] += line
          end

          nil
        end

        private

        def flush_last_field
          @last_field or return

          @record.send "#{@last_field[:name]}=", @last_field[:value].chomp
          @last_field = nil
        end
      end
    end
  end
end
