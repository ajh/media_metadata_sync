require 'active_support'

lib = Pathname.new(__FILE__).dirname
require lib.join("media_metadata_sync/version")
#require lib.join('media_metadata_sync/script/itunes_to_musicbrainz')
require lib.join('media_metadata_sync/source/file_system')
#require lib.join('media_metadata_sync/source/itunes')
#require lib.join('media_metadata_sync/source/mb')

module MediaMetadataSync
end
