# frozen_string_literal: true

# Helper for counting database queries in tests
# Usage:
#   expect { some_code }.not_to exceed_query_limit(2)

module QueryCounter
  class Counter
    attr_reader :query_count

    def initialize
      @query_count = 0
      @queries = []
    end

    def call(_name, _started, _finished, _unique_id, payload)
      return if payload[:name] == "SCHEMA"
      return if payload[:sql] =~ /^(BEGIN|COMMIT|SAVEPOINT|RELEASE)/

      @query_count += 1
      @queries << payload[:sql]
    end

    def queries
      @queries
    end
  end

  def count_queries(&block)
    counter = Counter.new
    ActiveSupport::Notifications.subscribed(counter.method(:call), "sql.active_record", &block)
    counter.query_count
  end

  def queries_executed(&block)
    counter = Counter.new
    ActiveSupport::Notifications.subscribed(counter.method(:call), "sql.active_record", &block)
    counter.queries
  end
end

RSpec::Matchers.define :exceed_query_limit do |expected|
  match do |block|
    @query_count = count_queries(&block)
    @query_count > expected
  end

  failure_message do
    "Expected to run maximum #{expected} queries, but ran #{@query_count} queries"
  end

  failure_message_when_negated do
    "Expected to run more than #{expected} queries, but ran #{@query_count} queries"
  end

  supports_block_expectations
end

RSpec.configure do |config|
  config.include QueryCounter
end

