# frozen_string_literal: true

module Api
  module V1
    class ImportsController < BaseController
      def restaurants_json
        uploaded = params.require(:file)
        content = uploaded.respond_to?(:read) ? uploaded.read : uploaded.to_s

        result = Imports::RestaurantsJson::Process.call(json: content)

        status_code = result.success? ? :ok : :unprocessable_entity
        payload = { success: result[:success], logs: result[:logs] }
        render json: payload, status: status_code
      end
    end
  end
end

