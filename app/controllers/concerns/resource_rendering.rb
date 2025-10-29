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

  def render_not_found(error_key)
    render_error(I18n.t(error_key), status: :not_found)
  end

  def render_validation_error(details = nil)
    render_error(I18n.t("errors.validation_failed"), status: :unprocessable_entity, details: details)
  end

  def render_error(message, status: :unprocessable_entity, details: nil)
    payload = { error: { message: message } }
    payload[:error][:details] = details if details
    render json: payload, status: status
  end
end
