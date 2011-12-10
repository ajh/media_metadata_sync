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

  describe "when run against the real itunes", :integration do
    def self.using_test_itunes_library?
      app = Appscript.app('iTunes')
      track_path = Pathname.new app.file_tracks.first.location.get.to_s
      expected_root_path = Pathname.new(__FILE__).dirname.join('../files/itunes_library')
      track_path.to_s =~ %r/#{Regexp.escape expected_root_path.to_s}/
    end

    if !using_test_itunes_library?
      pending 'examples skipped. Launch itunes while pressing the option button and select the test library to run.'
    else

      after do
        # Ideally I'd copy the library to a tmp dir and point itunes to that.
        #
        # But since I can't control which library itunes uses, this is the poor
        # man's version.

        # quit itunes and wait
        system %q(echo "tell application \"iTunes\" to quit" | osascript)
        sleep 2

        # refresh library
        system "rm -rf spec/files/itunes_library && git checkout -- spec/files/itunes_library"
      end

      describe "read" do
        it "should add records to the queue" do
          itunes = described_class.new
          q = Queue.new
          itunes.read q

          wash = q.shift(true)
          wash.name.should == 'Wash'
          wash.rating.should == 40
          wash.album_rating.should == 80

          corduroy = q.shift(true)
          corduroy.name.should == 'Corduroy'
          corduroy.rating.should == 60
          corduroy.album_rating.should == 80

          hail_hail = q.shift(true)
          hail_hail.name.should == 'Hail Hail'
          hail_hail.rating.should == 80
          hail_hail.album_rating.should == 80

          wws = q.shift(true)
          wws.name.should == 'World Wide Suicide'
          wws.rating.should == 100
          wws.album_rating.should == 80

          q.shift(true).should == 'alldone'
        end
      end

      describe "write" do
        it "should update a record in library" do
          record = MediaMetadataSync::Record.new
          record.rating = 60
          record.rated_at = time = Time.now
          record.itunes_id = '028DA9DC75BAA710'

          q = Queue.new
          q << record
          q << 'alldone'

          itunes = described_class.new
          itunes.write q

          app = Appscript.app('iTunes')
          app.file_tracks[3].rating.get.should == 60

          dates = YAML.load app.file_tracks[3].comment.get
          dates['rated_at'].should == time
        end
      end
    end
  end
end
