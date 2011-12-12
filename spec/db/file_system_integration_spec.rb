require 'helper'

describe MediaMetadataSync::DB::FileSystem, :integration do
  context "when working against a real filesystem" do
    describe "#read" do
      it "should add records to the queue" do
        f = described_class.new Pathname.new(__FILE__).dirname.join('../files')
        q = Queue.new
        f.read q

        records = []
        while (r = q.pop) != 'alldone'
          records << r
        end

        mp3_dir = Pathname.new(__FILE__).dirname.join("../files/itunes_library/iTunes Media/Music/Pearl Jam/The Gorge Amphitheatre George, WA 22July06")

        r = records.find{|r| r.name == 'Wash'}
        r.location.should == mp3_dir.join('1-01 Wash.mp3')
        r.music_brainz_id.should == 'bee8e0bf-128d-46a8-860a-4b4c21a06e08'

        r = records.find{|r| r.name == 'Corduroy'}
        r.location.should == mp3_dir.join('1-02 Corduroy.mp3')
        r.music_brainz_id.should == '0c3e7f56-6cc1-4526-8195-4ce90ccb6b05'

        r = records.find{|r| r.name == 'Hail, Hail'}
        r.location.should == mp3_dir.join('1-03 Hail Hail.mp3')
        r.music_brainz_id.should == 'c9099882-c2e3-44bb-a7a6-bc289cc0b29b'

        r = records.find{|r| r.name == 'World Wide Suicide'}
        r.location.should == mp3_dir.join('1-04 World Wide Suicide.mp3')
        r.music_brainz_id.should == '42777f0b-6084-4259-9aec-f2af2617cfed'
      end
    end
  end
end
