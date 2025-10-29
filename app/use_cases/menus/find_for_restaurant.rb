# frozen_string_literal: true

module Menus
  class FindForRestaurant < Micro::Case
    attributes :restaurant, :id, :repo

    def call!
      return Failure(:invalid, result: { error: I18n.t('errors.restaurants.not_found') }) if restaurant.nil?

      menu = if repo
                repo.find_for_restaurant(restaurant, id)
              else
                restaurant
                  .menus
                  .includes(menu_item_placements: :menu_item)
                  .find_by(id: id)
              end

      return Failure(:not_found, result: { error: I18n.t('errors.menus.not_found') }) if menu.nil?

      Success result: { menu: menu }
    end
  end
end

