# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      include Pagy::Backend if defined?(Pagy)
      include NestedResource
      include ResourceRendering
      include ResourceActions
      include RepositoryInjection

      rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
      rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
      rescue_from StandardError, with: :handle_unexpected_error

      DEFAULT_PER_PAGE = 100

      private

      # Paginates an AR::Relation. Returns the records; also sets pagination headers when available.
      def paginate(scope)
        return scope unless pagy_available?

        pagy_obj, records = pagy(scope, items: per_page_param)
        pagy_headers_merge(pagy_obj)
        records
      rescue Pagy::OverflowError
        handle_pagination_overflow(scope)
      end

      def pagy_available?
        defined?(Pagy)
      end

      def per_page_param
        (params[:per_page] || default_per_page).to_i
      end

      def default_per_page
        defined?(Pagy::DEFAULT) ? Pagy::DEFAULT[:items] : DEFAULT_PER_PAGE
      end

      def handle_pagination_overflow(scope)
        # If page out of range, return empty set and headers for last page
        empty = scope.none
        pagy_obj, = pagy(empty)
        pagy_headers_merge(pagy_obj)
        empty
      end

      # Use common X-* header names
      def pagy_headers_merge(pagy_obj)
        headers.merge!(
          "X-Current-Page" => pagy_obj.page.to_s,
          "X-Per-Page" => pagy_obj.items.to_s,
          "X-Total" => pagy_obj.count.to_s,
          "X-Total-Pages" => pagy_obj.pages.to_s
        )
      end

      def handle_not_found
        render json: { error: { message: I18n.t("errors.not_found") } }, status: :not_found
      end

      def handle_parameter_missing(exception)
        render json: {
          error: {
            message: I18n.t("errors.validation_failed"),
            details: [exception.message]
          }
        }, status: :unprocessable_entity
      end

      def handle_unexpected_error(exception)
        notify_error(exception)
        render json: { error: { message: I18n.t("errors.unexpected_error") } }, status: :internal_server_error
      end

      def notify_error(exception)
        ErrorReporter.current.notify(exception, context: error_context)
      end

      def error_context
        {
          controller: self.class.name,
          action: action_name,
          params: request.filtered_parameters
        }
      end
    end
  end
end
