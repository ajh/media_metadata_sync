require 'rbrainz'

class MusicBrainzClient
  include MusicBrainz # from rbrainz gem

  def initialize(username, password)
    @ws = Webservice::Webservice.new :username => username, :password => password
    @query = Webservice::Query.new @ws, :client_id => "Shngn1's rating sync tool"
  end

  def track_rating(mbid)
    # todo cache the mbid in a LRU cache
    mbid = Model::MBID.new mbid, :track
    @query.get_user_rating(mbid).value
  end

  # this is weird, two args?!
  def track_rating=(mbid, rating)
    mbid = Model::MBID.new mbid, :track
    @query.submit_user_rating mbid, rating
  end
end

client = MusicBrainzClient.new 'shngn1', 'uv@Q*kc8'
mbid = 'e4f9d618-61eb-491c-92fa-217551e402fe' # army reserve

puts client.track_rating mbid
