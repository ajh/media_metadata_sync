require 'helper'

describe MediaMetadataSync::DB::ITunes, :integration do
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
