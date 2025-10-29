# frozen_string_literal: true

module Menus
  class ListForRestaurant < Micro::Case
    include UseCaseHelpers

    attributes :restaurant, :repo

    def call!
      # Guard clauses: validate inputs
      return failure_not_found(:restaurant) unless restaurant

      Success result: { menus: fetch_menus }
    rescue StandardError => e
      handle_error(e, "menus.list_for_restaurant", restaurant_id: restaurant&.id)
    end

    private

    def fetch_menus
      return repo.for_restaurant(restaurant) if repo

      restaurant.menus.with_items.ordered
    end
  end
end
