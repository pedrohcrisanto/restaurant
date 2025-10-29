# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      # Pagination support (no-op if Pagy is not available)
      include Pagy::Backend if defined?(Pagy)

      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from StandardError, with: :render_unexpected_error

      private

      # Paginates an AR::Relation. Returns the records; also sets pagination headers when available.
      def paginate(scope)
        return scope unless defined?(Pagy)

        pagy_obj, records = pagy(scope, items: (params[:per_page] || (defined?(Pagy::DEFAULT) ? Pagy::DEFAULT[:items] : 100)).to_i)
        headers.merge!(pagy_headers_merge(pagy_obj)) if respond_to?(:pagy_headers_merge)
        records
      rescue Pagy::OverflowError
        # If page out of range, return empty set and headers for last page
        empty = scope.none
        pagy_obj, _ = pagy(empty)
        headers.merge!(pagy_headers_merge(pagy_obj)) if respond_to?(:pagy_headers_merge)
        empty
      end

      def render_not_found
        render json: { error: { message: I18n.t('errors.not_found') } }, status: :not_found
      end

      def render_unexpected_error(exception)
        ErrorReporter.current.notify(exception, context: {
          controller: self.class.name,
          action: action_name,
          params: request.filtered_parameters
        })
        render json: { error: { message: I18n.t('errors.unexpected_error') } }, status: :internal_server_error
      end

      def render_error(message, status: :unprocessable_entity, details: nil)
        payload = { error: { message: message } }
        payload[:error][:details] = details if details
        render json: payload, status: status
      end
    end
  end
end
