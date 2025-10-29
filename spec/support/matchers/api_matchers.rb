# frozen_string_literal: true

# Custom RSpec matchers for API testing
# Following Ruby and RSpec community best practices

RSpec::Matchers.define :have_http_status_ok do
  match do |response|
    response.status == 200
  end

  failure_message do |response|
    "expected HTTP status 200, but got #{response.status}"
  end
end

RSpec::Matchers.define :have_http_status_created do
  match do |response|
    response.status == 201
  end

  failure_message do |response|
    "expected HTTP status 201, but got #{response.status}"
  end
end

RSpec::Matchers.define :have_http_status_no_content do
  match do |response|
    response.status == 204
  end

  failure_message do |response|
    "expected HTTP status 204, but got #{response.status}"
  end
end

RSpec::Matchers.define :have_http_status_not_found do
  match do |response|
    response.status == 404
  end

  failure_message do |response|
    "expected HTTP status 404, but got #{response.status}"
  end
end

RSpec::Matchers.define :have_http_status_unprocessable_entity do
  match do |response|
    response.status == 422
  end

  failure_message do |response|
    "expected HTTP status 422, but got #{response.status}"
  end
end

RSpec::Matchers.define :return_json_with do |expected_keys|
  match do |response|
    @json = JSON.parse(response.body)
    expected_keys.all? { |key| @json.key?(key.to_s) }
  rescue JSON::ParserError
    false
  end

  failure_message do |response|
    if @json
      "expected JSON to have keys #{expected_keys}, but got #{@json.keys}"
    else
      "expected valid JSON response, but got: #{response.body}"
    end
  end
end

RSpec::Matchers.define :return_json_array do
  match do |response|
    @json = JSON.parse(response.body)
    @json.is_a?(Array)
  rescue JSON::ParserError
    false
  end

  failure_message do |response|
    if @json
      "expected JSON array, but got #{@json.class}"
    else
      "expected valid JSON response, but got: #{response.body}"
    end
  end
end

RSpec::Matchers.define :return_error_with_message do |expected_message|
  match do |response|
    @json = JSON.parse(response.body)
    @json["error"]&.include?(expected_message) || @json["message"]&.include?(expected_message)
  rescue JSON::ParserError
    false
  end

  failure_message do |response|
    if @json
      "expected error message to include '#{expected_message}', but got: #{@json}"
    else
      "expected valid JSON response, but got: #{response.body}"
    end
  end
end

RSpec::Matchers.define :have_content_type_json do
  match do |response|
    response.content_type&.include?("application/json")
  end

  failure_message do |response|
    "expected Content-Type to be application/json, but got #{response.content_type}"
  end
end

