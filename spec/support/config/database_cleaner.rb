# frozen_string_literal: true

# RSpec/ActiveRecord transactional tests configuration
# We avoid DatabaseCleaner and rely on Rails transactions for speed and simplicity.

RSpec.configure do |config|
  # Use transactions for most tests (fastest)
  config.use_transactional_fixtures = true

  # If you need to disable transactions for a specific example, tag it with :no_transaction
  # and we will wrap it in a truncation before/after (simple, gem-free approach).
  config.around(:each, :no_transaction) do |example|
    # Disable transactional fixtures temporarily
    orig = config.use_transactional_fixtures
    config.use_transactional_fixtures = false

    # Truncate all tables before and after to ensure a clean state
    connection = ActiveRecord::Base.connection
    begin
      connection.disable_referential_integrity do
        ActiveRecord::Base.descendants.each do |model|
          next unless model.table_exists?
          connection.execute("TRUNCATE TABLE #{connection.quote_table_name(model.table_name)} RESTART IDENTITY CASCADE")
        end
      end
    rescue StandardError
      # Fallback: purge if truncate is not supported
      ActiveRecord::Base.connection.tables.each do |table|
        next if table == ActiveRecord::SchemaMigration.table_name
        connection.execute("DELETE FROM #{connection.quote_table_name(table)}")
      end
    end

    example.run
  ensure
    # Clean again after
    begin
      connection.disable_referential_integrity do
        ActiveRecord::Base.descendants.each do |model|
          next unless model.table_exists?
          connection.execute("TRUNCATE TABLE #{connection.quote_table_name(model.table_name)} RESTART IDENTITY CASCADE")
        end
      end
    rescue StandardError
      ActiveRecord::Base.connection.tables.each do |table|
        next if table == ActiveRecord::SchemaMigration.table_name
        connection.execute("DELETE FROM #{connection.quote_table_name(table)}")
      end
    end

    config.use_transactional_fixtures = orig
  end
end

