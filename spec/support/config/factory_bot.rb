# frozen_string_literal: true

# FactoryBot configuration
# Following FactoryBot best practices

RSpec.configure do |config|
  # Include FactoryBot methods
  config.include FactoryBot::Syntax::Methods

  # Lint factories before running tests (optional, can be slow)
  # Uncomment to enable factory linting
  # config.before(:suite) do
  #   FactoryBot.lint
  # end

  # Use build_stubbed by default for faster tests (optional)
  # This creates objects without hitting the database
  # Uncomment if you want to use this pattern
  # config.before(:each) do
  #   FactoryBot.use_build_stubbed_by_default = true
  # end
end

# FactoryBot configuration
FactoryBot.define do
  # Ensure sequences are unique across test runs
  to_create { |instance| instance.save! }
end

