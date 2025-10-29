# frozen_string_literal: true

module Restaurants
  class Find < Micro::Case
    include UseCaseHelpers

    attributes :repo, :id

    def call!
      # Guard clauses: validate inputs
      return failure_missing_repo unless repo
      return failure_validation_failed unless id

      restaurant = fetch_restaurant
      return failure_not_found(:restaurant) unless restaurant

      Success result: { restaurant: restaurant }
    rescue StandardError => e
      handle_error(e, "restaurants.find", id: id)
    end

    private

    def fetch_restaurant
      repo.find(id)
    end
  end
end
