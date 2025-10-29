# frozen_string_literal: true

# Database helpers for testing
# Following Rails testing best practices
module DatabaseHelpers
  # Execute block without database cleaner
  def without_database_cleaner(&block)
    DatabaseCleaner.clean_with(:truncation)
    block.call
  ensure
    DatabaseCleaner.clean_with(:truncation)
  end

  # Disable foreign key checks temporarily (use with caution)
  def without_foreign_keys(&block)
    connection = ActiveRecord::Base.connection
    connection.disable_referential_integrity(&block)
  end

  # Get table row count
  def table_count(table_name)
    ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM #{table_name}")
  end

  # Truncate specific tables
  def truncate_tables(*table_names)
    table_names.each do |table_name|
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name} CASCADE")
    end
  end

  # Reset primary key sequences
  def reset_sequences(*table_names)
    table_names.each do |table_name|
      ActiveRecord::Base.connection.reset_pk_sequence!(table_name)
    end
  end

  # Check if record exists in database
  def exists_in_db?(model_class, id)
    model_class.exists?(id)
  end

  # Reload all associations
  def reload_all(*records)
    records.each(&:reload)
  end

  # Create record bypassing validations (use with caution)
  def create_invalid_record(model_class, attributes)
    record = model_class.new(attributes)
    record.save(validate: false)
    record
  end

  # Get SQL for ActiveRecord relation
  def to_sql(relation)
    relation.to_sql
  end

  # Explain query plan
  def explain_query(relation)
    relation.explain
  end

  # Count queries executed in block
  def count_queries(&block)
    queries = []
    counter = ->(*, payload) do
      queries << payload[:sql] unless payload[:name] == "SCHEMA"
    end

    ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &block)
    queries.size
  end

  # Get all queries executed in block
  def capture_queries(&block)
    queries = []
    counter = ->(*, payload) do
      queries << payload[:sql] unless payload[:name] == "SCHEMA"
    end

    ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &block)
    queries
  end

  # Check if query is N+1
  def has_n_plus_one?(relation, association_name, threshold: 2)
    query_count = count_queries do
      relation.each do |record|
        record.send(association_name).to_a
      end
    end

    query_count > threshold
  end
end

RSpec.configure do |config|
  config.include DatabaseHelpers
end

