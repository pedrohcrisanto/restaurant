# frozen_string_literal: true

# Database Cleaner configuration
# Following Rails testing best practices

RSpec.configure do |config|
  # Use transactions for most tests (fastest)
  config.use_transactional_fixtures = true

  # For tests that need to test transactions or use Capybara
  config.around(:each, :no_transaction) do |example|
    self.use_transactional_tests = false
    example.run
    self.use_transactional_tests = true
  end

  # Clean database before suite
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  # Use transactions by default
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  # Use truncation for JavaScript tests or tests marked with :no_transaction
  config.before(:each, :js) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each, :no_transaction) do
    DatabaseCleaner.strategy = :truncation
  end

  # Start DatabaseCleaner
  config.before(:each) do
    DatabaseCleaner.start
  end

  # Clean after each test
  config.after(:each) do
    DatabaseCleaner.clean
  end
end

