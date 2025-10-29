# frozen_string_literal: true

module Restaurants
  class Create < Micro::Case
    include UseCaseHelpers

    attributes :repo, :params

    def call!
      # Guard clauses: validate inputs
      return failure_missing_repo unless repo
      return failure_missing_params unless params

      restaurant = build_restaurant
      return failure_validation(restaurant) unless save_restaurant(restaurant)

      Success result: { restaurant: restaurant }
    rescue StandardError => e
      handle_error(e, "restaurants.create", params: params)
    end

    private

    def build_restaurant
      repo.build(params)
    end

    def save_restaurant(restaurant)
      repo.save(restaurant)
    end
  end
end
