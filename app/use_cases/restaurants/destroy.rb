# frozen_string_literal: true

module Restaurants
  class Destroy < Micro::Case
    include UseCaseHelpers

    attributes :repo, :restaurant

    def call!
      # Guard clauses: validate inputs
      return failure_missing_repo unless repo
      return failure_not_found(:restaurant) unless restaurant

      destroy_restaurant
      Success result: { destroyed: true }
    rescue StandardError => e
      handle_error(e, "restaurants.destroy", restaurant_id: restaurant&.id)
    end

    private

    def destroy_restaurant
      repo.destroy(restaurant)
    end
  end
end
