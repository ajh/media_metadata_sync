require 'active_support/all'
require 'pathname'

lib = Pathname.new(__FILE__).dirname
#require lib.join('media_metadata_sync/script/itunes_to_musicbrainz')
#require lib.join('media_metadata_sync/db/mb')
require lib.join("media_metadata_sync/config").to_s
require lib.join("media_metadata_sync/db/music_brainz").to_s
require lib.join("media_metadata_sync/version").to_s
require lib.join('media_metadata_sync/db/file_system').to_s
require lib.join('media_metadata_sync/db/itunes').to_s
require lib.join('media_metadata_sync/db/local').to_s
require lib.join('media_metadata_sync/record').to_s
