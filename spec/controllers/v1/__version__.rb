RSpec.configure do |config|
  # Version API
  config.before(:example) { @version = '/v1' }
end