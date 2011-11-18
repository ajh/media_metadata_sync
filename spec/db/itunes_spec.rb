require 'helper'

describe MediaMetadataSync::DB::ITunes do
  describe "read" do
    it "should do something painful" do
      pending 'stubbing of apple script'
      q = Queue.new

      described_class.read q
      q.length.should >= 1
      r = q.shift
      puts r.inspect
      r.should be_a(MediaMetadataSync::Record)
      r.rating.should be_present
      r.album_rating.should be_present
      File.exist?(r.location).should be_true
    end
  end
end
