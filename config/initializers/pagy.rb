# frozen_string_literal: true

# Pagy configuration with API headers extra and default items per page.
begin
  require "pagy"
  require "pagy/extras/headers"

  Pagy::DEFAULT[:items] = 100
rescue LoadError => e
  Rails.logger.warn("Pagy not loaded: #{e.message}. Pagination will be a no-op until the gem is installed.")
end
