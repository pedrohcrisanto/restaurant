# frozen_string_literal: true

# Request helpers for API testing
# Following Ruby and Rails community best practices
module RequestHelpers
  # Parse JSON response body
  def json_response
    @json_response ||= JSON.parse(response.body)
  end

  # Parse JSON response with symbolized keys
  def json_response_symbolized
    @json_response_symbolized ||= JSON.parse(response.body, symbolize_names: true)
  end

  # Clear cached JSON response
  def clear_json_cache
    @json_response = nil
    @json_response_symbolized = nil
  end

  # Make authenticated request (for future use)
  def authenticated_headers(user = nil)
    token = generate_jwt_token(user) if user
    {
      "Authorization" => "Bearer #{token}",
      "Content-Type" => "application/json",
      "Accept" => "application/json",
    }
  end

  # Standard JSON headers
  def json_headers
    {
      "Content-Type" => "application/json",
      "Accept" => "application/json",
    }
  end

  # Make GET request with JSON headers
  def json_get(path, **options)
    get path, headers: json_headers.merge(options[:headers] || {})
    clear_json_cache
  end

  # Make POST request with JSON headers
  def json_post(path, params: {}, **options)
    post path,
         params: params.to_json,
         headers: json_headers.merge(options[:headers] || {})
    clear_json_cache
  end

  # Make PUT request with JSON headers
  def json_put(path, params: {}, **options)
    put path,
        params: params.to_json,
        headers: json_headers.merge(options[:headers] || {})
    clear_json_cache
  end

  # Make PATCH request with JSON headers
  def json_patch(path, params: {}, **options)
    patch path,
          params: params.to_json,
          headers: json_headers.merge(options[:headers] || {})
    clear_json_cache
  end

  # Make DELETE request with JSON headers
  def json_delete(path, **options)
    delete path, headers: json_headers.merge(options[:headers] || {})
    clear_json_cache
  end

  # Extract error message from response
  def error_message
    json_response.dig("error", "message")
  end

  # Extract error details from response
  def error_details
    json_response.dig("error", "details") || []
  end

  # Check if response contains specific error
  def has_error?(message)
    error_message&.include?(message) || error_details.any? { |d| d.include?(message) }
  end

  private

  # Generate JWT token (placeholder for future implementation)
  def generate_jwt_token(user)
    # TODO: Implement JWT token generation
    "fake-jwt-token"
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end

