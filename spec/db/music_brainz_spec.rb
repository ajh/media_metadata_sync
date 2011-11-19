require 'helper'

describe MediaMetadataSync::DB::MusicBrainz do
  describe "#initialize" do
    it "should return take login info" do
      mb = described_class.new 'some_user', "some_pass"
      mb.user.should == 'some_user'
      mb.password.should == 'some_pass'
    end
  end

  describe "#write", :integration do
    it "should apply rating" do
      pending 'change name of app and define a good user agent'
      # see http://lists.musicbrainz.org/pipermail/musicbrainz-devel/2011-July/004365.html

      q = Queue.new
      q << MediaMetadataSync::Record.new(:name => 'some name', :rating => 50, :music_brainz_id => '34f8a2f4-0476-4d6e-937f-b9ba9cbc7926')
      q << :finish

      mb = described_class.new \
        MediaMetadataSync::Config.music_brainz.user,
        MediaMetadataSync::Config.music_brainz.password

      mb.write q
      MusicBrainz::Client.debug_output
      MusicBrainz::Client.headers "User-Agent" => "MediaMetadataSync#{MediaMetadataSync::VERSION}"

    #     headers 'Accept' => 'text/html'
      brainz = MusicBrainz::Client.new \
        MediaMetadataSync::Config.music_brainz.user,
        MediaMetadataSync::Config.music_brainz.password
      puts brainz.rating(:recording_id => '34f8a2f4-0476-4d6e-937f-b9ba9cbc7926').inspect
    end
  end
end
