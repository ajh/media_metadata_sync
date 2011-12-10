require 'helper'
require 'tempfile'

describe MediaMetadataSync::DB::Local do
  describe "initialize" do
    it "should create a database" do
      begin
        described_class.new "some_db.db"
        File.exists?("some_db.db").should be_true

      ensure
        # I'd rather create a db in a tempdir, but that didn't work for some reason.
        FileUtils.remove "some_db.db"
      end
    end
  end

  describe "write" do
    it "should insert records" do
      time = Time.now.utc

      q = Queue.new
      q << MediaMetadataSync::Record.new(:name => 'some name', :rating => 50, :rated_at => time)
      q << "alldone"

      begin
        local = described_class.new 'some_db.db'
        local.write q
        db = local.instance_variable_get '@db'
        rows = db.execute("select * from recordings")
        rows.length.should == 1
        r = rows.first
        r['name'].should == 'some name'
        r['rating'].should == 50
        r['rated_at'].should == time.iso8601
      ensure
        FileUtils.remove "some_db.db"
      end
    end
  end

  describe "read" do
    it "should add records to the queue" do
      time = Time.now.utc

      begin
        local = described_class.new 'some_db.db'
        db = local.instance_variable_get '@db'
        db.execute("insert into recordings values (:album_rating, :location, :music_brainz_id, :name, :rating, :rated_at)", :name => "some name", :rating => 50, :rated_at => time.iso8601)

        q = Queue.new
        local.read q

        record = q.shift(true)
        record.name.should == "some name"
        record.rating.should == 50
        record.rated_at.iso8601.should == time.iso8601

        q.shift(true).should == 'alldone'
        expect {q.shift(true)}.to raise_error(ThreadError)

      ensure
        FileUtils.remove "some_db.db"
      end
    end
  end
end
