# frozen_string_literal: true

module Restaurants
  class Create < Micro::Case
    attributes :repo, :params

    def call!
      restaurant = repo.build(params)
      if repo.save(restaurant)
        Success result: { restaurant: restaurant }
      else
        Failure :invalid, result: { error: restaurant.errors.full_messages }
      end
    end
  end
end

