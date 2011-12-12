require 'helper'

describe MediaMetadataSync::DB::FileSystem::EyeD3Parser do
  describe "#readline" do
    it "should return a record when a new one is found" do
      subject.readline "===== a_path/file.mp3 =====\n"
      record = subject.readline "===== a_path/another_file.mp3 =====\n"
      record.should be_a(MediaMetadataSync::Record)
      record.location.should == Pathname.new('a_path/file.mp3')
    end

    it "should set records name value" do
      subject.readline "===== a_path/file.mp3 =====\n"
      subject.readline "title: Breakerfall		artist: Pearl Jam\n"
      record = subject.readline "===== a_path/another_file.mp3 =====\n"
      record.name.should == 'Breakerfall'
    end

    it "should set records music_brainz_id value" do
      subject.readline "===== a_path/file.mp3 =====\n"
      subject.readline "Unique File ID: [http://musicbrainz.org] 8bdf1863-26a3-450f-89af-3f5bf057a76e\n"
      record = subject.readline "===== a_path/another_file.mp3 =====\n"
      record.music_brainz_id.should == '8bdf1863-26a3-450f-89af-3f5bf057a76e'
    end

    it "should set music_brainz_id even when split on multiple lines" do
      subject.readline "===== a_path/file.mp3 =====\n"
      subject.readline "Unique File ID: [http://musicbrainz.org]\n"
      subject.readline "8bdf1863-26a3-450f-89af-3f5bf057a76e\n"
      record = subject.readline "===== a_path/another_file.mp3 =====\n"
      record.music_brainz_id.should == '8bdf1863-26a3-450f-89af-3f5bf057a76e'
    end
  end

#===== spec/files/sample_file.mp3 =====

#sample_file.mp3	[ 3.33 MB ]
#-------------------------------------------------------------------------------
#Time: 02:19	MPEG1, Layer III	[ ~199 kb/s @ 44100 Hz - Joint stereo ]
#-------------------------------------------------------------------------------
#ID3 v2.4:
#title: Breakerfall		artist: Pearl Jam
#album: Binaural		year: 2000
#track: 1/13		genre: Rock (id 17)
#Publisher/label: Epic
#Unique File ID: [http://musicbrainz.org] 8bdf1863-26a3-450f-89af-3f5bf057a76e

#UserTextFrame: [Description: ALBUMARTISTSORT]
#Pearl Jam
#UserTextFrame: [Description: MusicBrainz Album Type]
#album
#UserTextFrame: [Description: MusicBrainz Album Artist Id]
#83b9cbe7-9857-49e2-ab8e-b57b01038103
#UserTextFrame: [Description: MusicBrainz Artist Id]
#83b9cbe7-9857-49e2-ab8e-b57b01038103
#UserTextFrame: [Description: BARCODE]
#5099749459021
#UserTextFrame: [Description: MusicBrainz Album Id]
#bb5ff209-9cef-45d7-97f9-00d68bae1cc7
#UserTextFrame: [Description: ASIN]
#B00004T8RK
#UserTextFrame: [Description: CATALOGNUMBER]
#494590 2
#UserTextFrame: [Description: MusicBrainz Album Release Country]
#XE
#UserTextFrame: [Description: MusicBrainz Album Status]
#official
end
