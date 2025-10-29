# frozen_string_literal: true

module Restaurants
  class List < Micro::Case
    include UseCaseHelpers

    attributes :repo

    def call!
      # Guard clause: validate repository presence
      return failure_missing_repo unless repo

      Success result: { relation: fetch_restaurants }
    rescue StandardError => e
      handle_error(e, "restaurants.list")
    end

    private

    def fetch_restaurants
      repo.relation_for_index
    end
  end
end
