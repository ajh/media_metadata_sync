require Pathname.new(__FILE__).dirname.join("../lib/media_metadata_sync")

RSpec.configure do |config|
  config.mock_framework = :rspec
end
