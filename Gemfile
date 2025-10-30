# frozen_string_literal: true

source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "ostruct"
gem "puma", ">= 5.0"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

# Use Case pattern for business logic
gem "u-case", "~> 4.5"

# API Blueprint serializer
gem "blueprinter", "~> 1.0"

# Pagination
gem "pagy", "~> 6.0"

# Rails i18n translations (framework messages)
gem "rails-i18n"

group :development, :test do
  gem "dotenv-rails"

  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  # Testing framework
  gem "rspec-rails", "~> 6.1"
  gem "rspec_junit_formatter", "~> 0.6", require: false

  # Test data generation
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.2"

  # RSpec matchers
  gem "shoulda-matchers", "~> 6.0"

  # Code coverage
  gem "simplecov", "~> 0.22", require: false

  # API documentation
  gem "rswag-specs", "~> 2.13"

  # Security scanners
  gem "brakeman", "~> 6.1", require: false
  gem "bundler-audit", "~> 0.9", require: false
end

group :development do
  # Code style and linting
  gem "rubocop", "~> 1.59", require: false
  gem "rubocop-rails", "~> 2.23", require: false
  gem "rubocop-rspec", "~> 2.26", require: false
  gem "reek", require: false
  gem "i18n-tasks", require: false
  gem "license_finder", require: false

  # API documentation UI
  gem "rswag-api", "~> 2.13"
  gem "rswag-ui", "~> 2.13"
end

group :test do
  # Tests use PostgreSQL in this project (the `pg` gem is declared globally above).
  # If you need a local lightweight DB for quick experiments, uncomment sqlite3 below.
  # gem "sqlite3", "~> 2.1"
end
