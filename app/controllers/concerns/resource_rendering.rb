# frozen_string_literal: true

module ResourceRendering
  extend ActiveSupport::Concern

  private

  def render_success(resource, blueprint_class, status: :ok)
    render json: blueprint_class.render_as_hash(resource), status: status
  end

  def render_created(resource, blueprint_class)
    render_success(resource, blueprint_class, status: :created)
  end

  def render_no_content
    head :no_content
  end

  def render_not_found(error_key_or_exception)
    if error_key_or_exception.respond_to?(:message)
      # Called via rescue_from which passes the exception
      render_error(error_key_or_exception.message, status: :not_found)
    else
      # Called with an i18n key string
      render_error(I18n.t(error_key_or_exception), status: :not_found)
    end
  end

  def render_validation_error(details = nil)
    # If the use case provided specific validation messages, expose them in
    # the `message` field (prefer a human-friendly single message). Otherwise
    # fall back to the generic validation failed message.
    message = if details.is_a?(String)
                details
              elsif details.is_a?(Array) && details.any?
                # Prefer the first validation message for simplicity
                details.first
              else
                I18n.t("errors.validation_failed")
              end

    render_error(message, status: :unprocessable_entity, details: details)
  end

  def render_error(message, status: :unprocessable_entity, details: nil)
    payload = { error: { message: message } }
    payload[:error][:details] = details if details
    render json: payload, status: status
  end
end
