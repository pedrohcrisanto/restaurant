# frozen_string_literal: true

module MenuItems
  class FindForRestaurant < Micro::Case
    include UseCaseHelpers

    attributes :restaurant, :id, :repo

    def call!
      # Guard clauses: validate inputs
      return failure_not_found(:restaurant) unless restaurant
      return failure_validation_failed unless id

      menu_item = fetch_menu_item
      return failure_not_found(:menu_item) unless menu_item

      Success result: { menu_item: menu_item }
    rescue StandardError => e
      handle_error(e, "menu_items.find_for_restaurant", restaurant_id: restaurant&.id, item_id: id)
    end

    private

    def fetch_menu_item
      return repo.find_by_restaurant(restaurant, id) if repo

      MenuItem.for_restaurant(restaurant).find_by(id: id)
    end
  end
end
