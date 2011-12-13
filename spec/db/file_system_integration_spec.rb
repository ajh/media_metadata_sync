require 'helper'
require 'tmpdir'

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

    describe "#write" do
      it "should update metadata" do
        Dir.mktmpdir do |path|
          path = Pathname.new path
          FileUtils.cp Pathname.new(__FILE__).dirname.join('../files/sample_file.mp3'), path

          time = 1.day.ago
          record = MediaMetadataSync::Record.new \
            :location => path.join('sample_file.mp3'),
            :rating => 20,
            :rated_at => time

          q = Queue.new
          q << record
          q << 'alldone'

          f = described_class.new path
          f.write q

          output = `eyeD3 --no-color #{Shellwords.shellescape path.join("sample_file.mp3").to_s}`
          output.should match(/UserTextFrame: \[Description: mms_rating\]\n20 #{time.iso8601}/)
        end
      end
    end
  end
end
