require 'configuration'

module MediaMetadataSync
  Configuration.load Pathname.new(__FILE__).dirname.join('../../config')
  Config = Configuration.for 'test'
end
