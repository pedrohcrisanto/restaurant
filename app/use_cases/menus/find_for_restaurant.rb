# frozen_string_literal: true

module Menus
  class FindForRestaurant < Micro::Case
    include UseCaseHelpers

    attributes :restaurant, :id, :repo

    def call!
      # Guard clauses: validate inputs
      return failure_not_found(:restaurant) unless restaurant
      return failure_validation_failed unless id

      menu = fetch_menu
      return failure_not_found(:menu) unless menu

      Success result: { menu: menu }
    rescue StandardError => e
      handle_error(e, "menus.find_for_restaurant", restaurant_id: restaurant&.id, menu_id: id)
    end

    private

    def fetch_menu
      return repo.find_by_restaurant(restaurant, id) if repo

      restaurant.menus.with_items.find_by(id: id)
    end
  end
end
