require 'active_support'
require 'pathname'

lib = Pathname.new(__FILE__).dirname
#require lib.join('media_metadata_sync/script/itunes_to_musicbrainz')
#require lib.join('media_metadata_sync/source/mb')
require lib.join("media_metadata_sync/version")
require lib.join('media_metadata_sync/record')
require lib.join('media_metadata_sync/source/file_system')
require lib.join('media_metadata_sync/source/itunes')
require lib.join('media_metadata_sync/source/local')

module MediaMetadataSync
end
