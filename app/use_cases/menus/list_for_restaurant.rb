# frozen_string_literal: true

module Menus
  class ListForRestaurant < Micro::Case
    attributes :restaurant, :repo

    def call!
      return Failure(:invalid, result: { error: I18n.t('errors.restaurants.not_found') }) if restaurant.nil?

      menus = if repo
                  repo.relation_for_restaurant(restaurant)
                else
                  restaurant
                    .menus
                    .includes(menu_item_placements: :menu_item)
                    .order(:id)
                end

      Success result: { menus: menus }
    end
  end
end

