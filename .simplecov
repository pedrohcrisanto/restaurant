# frozen_string_literal: true

# SimpleCov configuration
# Run tests with: COVERAGE=true bundle exec rspec

SimpleCov.start "rails" do
  # Filters - exclude from coverage
  add_filter "/spec/"
  add_filter "/config/"
  add_filter "/vendor/"
  add_filter "/db/"
  add_filter "/lib/tasks/"

  # Groups - organize coverage report
  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Use Cases", "app/use_cases"
  add_group "Repositories", "app/repositories"
  add_group "Blueprints", "app/blueprints"
  add_group "Helpers", "app/helpers"
  add_group "Services", "app/services"

  # Coverage thresholds
  minimum_coverage 80
  minimum_coverage_by_file 70

  # Track files even if not loaded
  track_files "{app}/**/*.rb"

  # Formatters
  if ENV["CI"]
    require "simplecov-lcov"
    SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
    formatter SimpleCov::Formatter::LcovFormatter
  else
    formatter SimpleCov::Formatter::HTMLFormatter
  end
end

