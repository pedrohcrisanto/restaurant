# frozen_string_literal: true

module UseCaseHelpers
  extend ActiveSupport::Concern

  private

  # Generic error handler for use cases
  # @param exception [Exception] The exception to handle
  # @param context [String] The use case context (e.g., 'restaurants.create')
  # @param extra_context [Hash] Additional context to include in error report
  def handle_error(exception, context, **extra_context)
    ErrorReporter.current.notify(exception, context: { use_case: context, **extra_context })
    Failure(:error, result: { error: I18n.t("errors.unexpected_error") })
  end

  # Validation failure with model errors
  # @param record [ActiveRecord::Base, Exception] The record with errors or RecordInvalid exception
  def failure_validation(record)
    errors = if record.is_a?(ActiveRecord::RecordInvalid)
               record.record.errors.full_messages
             else
               record.errors.full_messages
             end
    Failure(:invalid, result: { error: errors })
  end

  # Generic not found failure
  # @param resource_type [Symbol] The type of resource (:restaurant, :menu, :menu_item)
  def failure_not_found(resource_type = :resource)
    error_key = "errors.#{resource_type.to_s.pluralize}.not_found"
    error_message = I18n.exists?(error_key) ? I18n.t(error_key) : I18n.t("errors.not_found")
    Failure(:not_found, result: { error: error_message })
  end

  # Generic validation failed
  def failure_validation_failed
    Failure(:invalid, result: { error: I18n.t("errors.validation_failed") })
  end

  # Missing params failure
  def failure_missing_params
    Failure(:invalid, result: { error: I18n.t("errors.validation_failed") })
  end

  # Missing repository failure
  def failure_missing_repo
    Failure(:invalid, result: { error: I18n.t("errors.validation_failed") })
  end

  # Missing name failure
  def failure_missing_name
    Failure(:invalid, result: { error: [I18n.t("errors.validation.name_required")] })
  end

  # Check if name is valid (present after stripping)
  # @param name [String, nil] The name to validate
  def valid_name?(name)
    name.to_s.strip.present?
  end

  # Normalize name (strip and squeeze spaces)
  # @param name [String, nil] The name to normalize
  def normalize_name(name)
    name.to_s.strip.squeeze(" ")
  end

  # Repository delegation helpers
  # These methods abstract the pattern: repo ? repo.method : model.method

  def build_with_repo(repo, model_class, *, **)
    repo ? repo.build(*, **) : model_class.new(*, **)
  end

  def save_with_repo(repo, record)
    repo ? repo.save(record) : record.save
  end

  def update_with_repo(repo, record, attributes)
    repo ? repo.update(record, attributes) : record.update(attributes)
  end

  def destroy_with_repo(repo, record)
    repo ? repo.destroy(record) : record.destroy
  end

  def find_with_repo(repo, model_class, id)
    repo ? repo.find(id) : model_class.find(id)
  end
end
