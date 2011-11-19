require "sqlite3"

module MediaMetadataSync
  module DB
    # a local sqlite database
    class Local
      def initialize(db_name="test.db")
        # Open a database
        @db = SQLite3::Database.new db_name, :results_as_hash => true
        create_table
      end

      def create_table
        @db.execute <<-SQL
          create table recordings (
            album_rating int,
            location varchar,
            music_brainz_id varchar,
            name varchar,
            rating int
          );
        SQL
      end

      INSERT_SQL = <<-SQL
        insert into recordings values (:album_rating, :location, :music_brainz_id, :name, :rating)
      SQL

      def write(queue)
        loop do
          value = queue.shift
          case value
          when MediaMetadataSync::Record
            @db.execute INSERT_SQL, value.to_hash
          when "alldone"
            break
          end
        end
      end

      def read(queue)
        @db.execute("select * from recordings") do |row|
          r = Record.new row.reject{|k,v| !Record.members.map(&:to_s).include?(k)}
          queue << r
        end

        queue << 'alldone' # hack job
      end
    end
  end
end
