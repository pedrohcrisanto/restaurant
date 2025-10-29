# frozen_string_literal: true

# Simple ErrorReporter with pluggable adapter (e.g., Sentry) via dependency injection.
# Usage:
#   ErrorReporter.current.notify(error, context: { user_id: 123 })
# Or inject an instance into use cases/controllers.
class ErrorReporter
  Adapter = Struct.new(:notify, keyword_init: true)

  def self.current
    @current ||= new
  end

  class << self
    attr_writer :current
  end

  def initialize(adapter: nil, logger: Rails.logger)
    @adapter = adapter
    @logger = logger
  end

  # Notify unexpected errors. Accepts Exception or message String.
  def notify(error, context: {})
    if @adapter.respond_to?(:notify)
      @adapter.notify(error, context: context)
    else
      # Fallback: structured log for future monitoring systems
      payload = {
        type: error.class.to_s,
        message: error.respond_to?(:message) ? error.message : error.to_s,
        backtrace: (error.backtrace if error.respond_to?(:backtrace)),
        context: context,
      }
      @logger.error({ error_reporter: payload }.to_json)
    end
  rescue StandardError => e
    # Ensure the reporter never raises
    @logger.error({ error_reporter_failure: { message: e.message } }.to_json)
  end
end
