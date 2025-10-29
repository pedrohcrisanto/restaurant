# frozen_string_literal: true

module Restaurants
  class Update < Micro::Case
    include UseCaseHelpers

    attributes :repo, :restaurant, :params

    def call!
      # Guard clauses: validate inputs
      return failure_missing_repo unless repo
      return failure_not_found(:restaurant) unless restaurant
      return failure_missing_params unless params

      return failure_validation(restaurant) unless update_restaurant

      Success result: { restaurant: restaurant }
    rescue StandardError => e
      handle_error(e, "restaurants.update", restaurant_id: restaurant&.id, params: params)
    end

    private

    def update_restaurant
      repo.update(restaurant, params)
    end
  end
end
