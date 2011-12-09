require 'helper'

describe MediaMetadataSync::DB::ITunes do
  def self.using_test_itunes_library?
    app = Appscript.app('iTunes')
    track_path = Pathname.new app.file_tracks.first.location.get.to_s
    expected_root_path = Pathname.new(__FILE__).dirname.join('../files/itunes_library')
    track_path.to_s =~ %r/#{Regexp.escape expected_root_path.to_s}/
  end

  if using_test_itunes_library?
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

  else
    pending 'examples skipped. Launch itunes while pressing the option button and select the test library to run.'
  end
end
