# frozen_string_literal: true

require 'bundler/setup'
require 'pry'
require 'silkey-sdk'
require 'rspec/expectations'
require 'factory_bot'
# require 'support/fixture_helpers'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.include FactoryBot::Syntax::Methods
  # config.include Helper

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
