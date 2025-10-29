# frozen_string_literal: true

# Custom RSpec matchers for use cases
# These matchers improve test readability and follow Ruby community best practices

RSpec::Matchers.define :be_a_success do
  match do |result|
    result.success?
  end

  failure_message do |result|
    "expected use case to be successful, but it failed with: #{result.data}"
  end

  failure_message_when_negated do
    "expected use case to fail, but it succeeded"
  end
end

RSpec::Matchers.define :be_a_failure do
  match do |result|
    result.failure?
  end

  failure_message do |result|
    "expected use case to fail, but it succeeded with: #{result.data}"
  end

  failure_message_when_negated do
    "expected use case to succeed, but it failed"
  end
end

RSpec::Matchers.define :fail_with_type do |expected_type|
  match do |result|
    result.failure? && result.type == expected_type
  end

  failure_message do |result|
    if result.success?
      "expected use case to fail with type :#{expected_type}, but it succeeded"
    else
      "expected failure type :#{expected_type}, but got :#{result.type}"
    end
  end
end

RSpec::Matchers.define :succeed_with_data do |expected_data|
  match do |result|
    return false unless result.success?

    expected_data.all? do |key, value|
      result.data[key] == value
    end
  end

  failure_message do |result|
    if result.failure?
      "expected use case to succeed with data #{expected_data}, but it failed"
    else
      "expected data to include #{expected_data}, but got #{result.data}"
    end
  end
end

RSpec::Matchers.define :have_error_message do |expected_message|
  match do |result|
    result.failure? && result.data.to_s.include?(expected_message)
  end

  failure_message do |result|
    if result.success?
      "expected use case to fail with message '#{expected_message}', but it succeeded"
    else
      "expected error message to include '#{expected_message}', but got '#{result.data}'"
    end
  end
end

RSpec::Matchers.define :be_persisted_record do
  match do |record|
    record.present? && record.persisted?
  end

  failure_message do |record|
    if record.nil?
      "expected a persisted record, but got nil"
    else
      "expected record to be persisted, but it has errors: #{record.errors.full_messages}"
    end
  end
end

RSpec::Matchers.define :have_validation_error do |attribute|
  match do |record|
    record.invalid? && record.errors.key?(attribute)
  end

  failure_message do |record|
    if record.valid?
      "expected record to have validation error on :#{attribute}, but record is valid"
    else
      "expected validation error on :#{attribute}, but got errors on: #{record.errors.keys}"
    end
  end
end

RSpec::Matchers.define :be_valid_json do
  match do |json_string|
    JSON.parse(json_string)
    true
  rescue JSON::ParserError
    false
  end

  failure_message do
    "expected valid JSON, but got invalid JSON"
  end
end

RSpec::Matchers.define :match_json_schema do |schema|
  match do |json_response|
    @errors = []
    validate_schema(json_response, schema)
    @errors.empty?
  end

  failure_message do
    "expected JSON to match schema, but got errors: #{@errors.join(', ')}"
  end

  def validate_schema(data, schema)
    schema.each do |key, type|
      unless data.key?(key.to_s) || data.key?(key.to_sym)
        @errors << "missing key: #{key}"
        next
      end

      value = data[key.to_s] || data[key.to_sym]
      next if value.nil?

      case type
      when :string
        @errors << "#{key} should be a String" unless value.is_a?(String)
      when :integer
        @errors << "#{key} should be an Integer" unless value.is_a?(Integer)
      when :float, :decimal
        @errors << "#{key} should be a Numeric" unless value.is_a?(Numeric)
      when :boolean
        @errors << "#{key} should be a Boolean" unless [true, false].include?(value)
      when :array
        @errors << "#{key} should be an Array" unless value.is_a?(Array)
      when :hash
        @errors << "#{key} should be a Hash" unless value.is_a?(Hash)
      end
    end
  end
end

RSpec::Matchers.define :include_json do |expected|
  match do |actual|
    @actual = JSON.parse(actual) if actual.is_a?(String)
    @actual ||= actual

    expected.all? do |key, value|
      @actual[key.to_s] == value || @actual[key.to_sym] == value
    end
  end

  failure_message do
    "expected JSON to include #{expected}, but got #{@actual}"
  end
end

