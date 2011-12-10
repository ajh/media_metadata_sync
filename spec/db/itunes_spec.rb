require 'helper'

describe MediaMetadataSync::DB::ITunes do
  describe "write" do
    before do
      @track = double 'track',
        :rating => (@rating = double('rating')),
        :comment => (@comment = double('comment'))

      # don't really use appscript
      Appscript.stub(:app).and_return(@itunes_app = double('itunes app'))
      described_class.any_instance.stub(:find_track_by_itunes_id => nil)
    end

    it "should update a stale value with a fresh value" do
      fresh_time = 1.day.ago
      stale_time = 2.days.ago

      @comment.stub :get => YAML.dump({'rated_at' => stale_time}), :set => true
      described_class.any_instance.stub(:find_track_by_itunes_id => @track)
      @rating.should_receive(:set).with(60).exactly(1).times

      record = MediaMetadataSync::Record.new
      record.rating = 60
      record.rated_at = fresh_time
      record.itunes_id = '028DA9DC75BAA710'

      q = Queue.new
      q << record
      q << 'alldone'

      itunes = described_class.new
      itunes.write q
    end

    it "should not update a fresh value with a stale value" do
      fresh_time = 1.day.ago
      stale_time = 2.days.ago

      @comment.stub :get => YAML.dump({'rated_at' => fresh_time})
      described_class.any_instance.stub(:find_track_by_itunes_id => @track)
      @rating.should_receive(:set).exactly(0).times

      record = MediaMetadataSync::Record.new
      record.rating = 60
      record.rated_at = stale_time
      record.itunes_id = '028DA9DC75BAA710'

      q = Queue.new
      q << record
      q << 'alldone'

      itunes = described_class.new
      itunes.write q
    end

    it "should not update when incoming value has no time" do
      fresh_time = 1.day.ago
      stale_time = 2.days.ago

      @comment.stub :get => ''
      described_class.any_instance.stub(:find_track_by_itunes_id => @track)
      @rating.should_receive(:set).exactly(0).times

      record = MediaMetadataSync::Record.new
      record.rating = 60

      q = Queue.new
      q << record
      q << 'alldone'

      itunes = described_class.new
      itunes.write q
    end

    it "should update when existing value has no time" do
      @comment.stub :get => '', :set => true
      described_class.any_instance.stub(:find_track_by_itunes_id => @track)
      @rating.should_receive(:set).with(60).exactly(1).times

      record = MediaMetadataSync::Record.new
      record.rating = 60
      record.rated_at = Time.now

      q = Queue.new
      q << record
      q << 'alldone'

      itunes = described_class.new
      itunes.write q
    end

    it "should update comments with dates when updating" do
      time = Time.now

      @comment.stub :get => ''
      @comment.should_receive(:set).with(YAML.dump({'rated_at' => time}))

      described_class.any_instance.stub(:find_track_by_itunes_id => @track)
      @rating.stub :set

      record = MediaMetadataSync::Record.new
      record.rating = 60
      record.rated_at = time

      q = Queue.new
      q << record
      q << 'alldone'

      itunes = described_class.new
      itunes.write q
    end
  end
end
