# frozen_string_literal: true

# Shoulda Matchers configuration
# Following Shoulda Matchers best practices

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

