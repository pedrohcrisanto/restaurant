# frozen_string_literal: true

module MenuItems
  class ListForRestaurant < Micro::Case
    include UseCaseHelpers

    attributes :restaurant, :repo

    def call!
      # Guard clause: validate restaurant presence
      return failure_not_found(:restaurant) unless restaurant

      Success result: { items: fetch_items }
    rescue StandardError => e
      handle_error(e, "menu_items.list_for_restaurant", restaurant_id: restaurant&.id)
    end

    private

    def fetch_items
      return repo.for_restaurant(restaurant) if repo

      MenuItem.for_restaurant(restaurant).ordered
    end
  end
end
