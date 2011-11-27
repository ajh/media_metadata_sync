require 'helper'
require 'httparty'

describe MediaMetadataSync::DB::MusicBrainz do
  # would be better to have this be a inheritable attr so avoid poluting
  # Object's namespace.
  class TestClient
    include HTTParty
    base_uri 'musicbrainz.org/ws/2'
    debug_output
    headers "User-Agent" => "MediaMetadataSync/#{MediaMetadataSync::VERSION} (https://github.com/ajh/media_metadata_sync)"
    digest_auth \
      MediaMetadataSync::Config.music_brainz.user,
      MediaMetadataSync::Config.music_brainz.password

    def initialize
    end
  end

  describe "#initialize" do
    it "should return take login info" do
      mb = described_class.new 'some_user', "some_pass"
      mb.user.should == 'some_user'
      mb.password.should == 'some_pass'
    end
  end

  describe "#write", :integration do
    xit "should apply rating" do
      #pending 'fixing the 401 auth issue when trying to see user-ratings'
      # I guess httparty won't work, because curl works:
      # curl 'http://musicbrainz.org/ws/2/recording/34f8a2f4-0476-4d6e-937f-b9ba9cbc7926?inc=user-ratings' --digest --user 'shngn_test:7n2SZDWwHf'
      q = Queue.new
      q << MediaMetadataSync::Record.new(:name => 'some name', :rating => 50, :music_brainz_id => '34f8a2f4-0476-4d6e-937f-b9ba9cbc7926')
      q << :finish

      #mb = described_class.new \
        #MediaMetadataSync::Config.music_brainz.user,
        #MediaMetadataSync::Config.music_brainz.password

      #mb.write q

      c = TestClient.new
      #TestClient.get('/recording/34f8a2f4-0476-4d6e-937f-b9ba9cbc7926', :query => {'inc' => 'user-rating'}).inspect
      #puts TestClient.get('/recording/34f8a2f4-0476-4d6e-937f-b9ba9cbc7926', :query => {}).inspect
      #puts TestClient.get('/recording', :query => {'client' => "MediaMetadataSync-#{MediaMetadataSync::VERSION}", "inc" => 'user-ratings'}).inspect
      #puts TestClient.get('/rating', :query => {'id' => '34f8a2f4-0476-4d6e-937f-b9ba9cbc7926', 'entity' => 'recording', 'client' => "MediaMetadataSync-#{MediaMetadataSync::VERSION}", :digest_auth => {:username => 'hi', :password => 'wront'}}).inspect
      puts HTTParty.get('http://musicbrainz.org/ws/2/recording/34f8a2f4-0476-4d6e-937f-b9ba9cbc7926',
        :query => {'client' => "MediaMetadataSync-#{MediaMetadataSync::VERSION}", "inc" => 'user-ratings'},
        :basic_auth => {:username => 'hi', :password => 'wrong'},
        :headers => {"User-Agent" => "MediaMetadataSync/#{MediaMetadataSync::VERSION} (https://github.com/ajh/media_metadata_sync)"}
      ).inspect
      #puts TestClient.get('/recording/34f8a2f4-0476-4d6e-937f-b9ba9cbc7926/rating', :query => {'client' => "MediaMetadataSync-#{MediaMetadataSync::VERSION}", "inc" => 'user-tags'}).inspect

      #puts brainz.send(:request,'/recording/34f8a2f4-0476-4d6e-937f-b9ba9cbc7926', 'inc' => 'user-rating').inspect
      #puts brainz.rating(:recording_id => '34f8a2f4-0476-4d6e-937f-b9ba9cbc7926', :client => "MediaMetadataSync-#{MediaMetadataSync::VERSION}").inspect
    end
  end
end
