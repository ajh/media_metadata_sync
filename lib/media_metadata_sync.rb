require 'active_support'
require 'pathname'

lib = Pathname.new(__FILE__).dirname
#require lib.join('media_metadata_sync/script/itunes_to_musicbrainz')
#require lib.join('media_metadata_sync/db/mb')
require lib.join("media_metadata_sync/config")
require lib.join("media_metadata_sync/db/music_brainz")
require lib.join("media_metadata_sync/version")
require lib.join('media_metadata_sync/db/file_system')
require lib.join('media_metadata_sync/db/itunes')
require lib.join('media_metadata_sync/db/local')
require lib.join('media_metadata_sync/record')

module MediaMetadataSync
end
