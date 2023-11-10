# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/" # Filters out spec directory from coverage
end

require "logger"
require "webmock/rspec"
require "logsnag"

# Require support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |file| require file }

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random
  Kernel.srand config.seed
end
