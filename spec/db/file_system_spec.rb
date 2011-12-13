require 'helper'

describe MediaMetadataSync::DB::FileSystem do
  describe "#initialize" do
    it "should take a root path" do
      f = described_class.new 'a/library/path'
      f.root_path.should == Pathname.new('a/library/path')
    end
  end

  describe "#write" do
    before do
      # don't run real commands
      described_class.any_instance.stub(:system)
    end

    it "should not write outside of root path" do
      q = Queue.new
      q << MediaMetadataSync::Record.new(
        :location => 'another/path', :rating => 50, :rated_at => Time.now)
      q << 'alldone'

      f = described_class.new 'some/path'
      f.should_not_receive(:system)
      f.write q
    end
    it "should write rating and rated_at" do
      time = 1.hour.ago
      q = Queue.new
      q << MediaMetadataSync::Record.new(
        :location => 'some/path/hi.mp3', :rating => 50, :rated_at => time)
      q << 'alldone'

      f = described_class.new 'some/path'
      f.should_receive(:system).with(match(/--set-user-text-frame mms_rating:\"50 #{time.iso8601}\"/))
      f.write q
    end
    it "should write album_rating and album_rated_at" do
      time = 1.hour.ago
      q = Queue.new
      q << MediaMetadataSync::Record.new(
        :location => 'some/path/hi.mp3', :album_rating => 50, :album_rated_at => time)
      q << 'alldone'

      f = described_class.new 'some/path'
      f.should_receive(:system).with(match(/--set-user-text-frame mms_album_rating:\"50 #{time.iso8601}\"/))
      f.write q
    end
    it "should write itunes_id"
    it "should write music_brainz_id"
    it "should not write name"
    it "should ignore records without location" do
      q = Queue.new
      q << MediaMetadataSync::Record.new
      q << 'alldone'

      f = described_class.new 'some/path'
      f.should_not_receive(:system)
      f.write q
    end
    it "should not update fresh rating with stale value"
    it "should not update fresh album_rating with stale value"
  end
end
