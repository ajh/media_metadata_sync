require Pathname.new(__FILE__).dirname.join("../lib/media_metadata_sync")

RSpec.configure do |config|
  config.mock_framework = :rspec
  config.treat_symbols_as_metadata_keys_with_true_values = true
end
