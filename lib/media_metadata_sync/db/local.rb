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
            rating int,
            rated_at text
          );
        SQL
      end

      INSERT_SQL = <<-SQL
        insert into recordings values (:album_rating, :location, :music_brainz_id, :name, :rating, :rated_at)
      SQL

      COLUMNS = [:album_rating, :location, :music_brainz_id, :name, :rating, :rated_at].freeze

      def write(queue)
        loop do
          record = queue.shift
          case record
          when MediaMetadataSync::Record
            values = record.members.inject({}) do |memo, field|
              COLUMNS.include?(field) or next memo

              if field.to_s =~ %r/_at$/ && record[field]
                memo[field] = record[field].iso8601
              else
                memo[field] = record[field]
              end

              memo
            end

            @db.execute INSERT_SQL, values

          when "alldone"
            break
          end
        end
      end

      def read(queue)
        @db.execute("select * from recordings") do |row|
          r = Record.new row.reject{|k,v| !Record.members.map(&:to_s).include?(k)}
          r.rated_at = Time.iso8601(r.rated_at) if r.rated_at
          queue << r
        end

        queue << 'alldone' # hack job
      end
    end
  end
end
