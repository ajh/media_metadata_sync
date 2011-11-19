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
      q = Queue.new
      q << MediaMetadataSync::Record.new(:name => 'some name', :rating => 50)
      q << "alldone"

      begin
        local = described_class.new 'some_db.db'
        local.write q
        db = local.instance_variable_get '@db'
        rows = db.execute("select * from recordings")
        rows.length.should == 1
        rows.first.should satisfy {|h|
          h['name'] == 'some name' && h['rating'] == 50
        }
      ensure
        FileUtils.remove "some_db.db"
      end
    end
  end

  describe "read" do
    it "should queue with records" do
      begin
        local = described_class.new 'some_db.db'
        db = local.instance_variable_get '@db'
        db.execute("insert into recordings values (:album_rating, :location, :music_brainz_id, :name, :rating)", :name => "some name", :rating => 50)

        q = Queue.new
        local.read q

        q.shift(true).should == MediaMetadataSync::Record.new(:name => "some name", :rating => 50)
        q.shift(true).should == 'alldone'
        expect {q.shift(true)}.to raise_error(ThreadError)

      ensure
        FileUtils.remove "some_db.db"
      end
    end
  end
end
