# frozen_string_literal: true

module MenuItems
  class FindForRestaurant < Micro::Case
    attributes :restaurant, :id, :repo

    def call!
      return Failure(:invalid, result: { error: I18n.t('errors.restaurants.not_found') }) if restaurant.nil?

      menu_item = if repo
                      repo.find_for_restaurant(restaurant, id)
                    else
                      MenuItem
                        .joins(:menus)
                        .where(menus: { restaurant_id: restaurant.id })
                        .distinct
                        .find_by(id: id)
                    end

      return Failure(:not_found, result: { error: I18n.t('errors.menu_items.not_found') }) if menu_item.nil?

      Success result: { menu_item: menu_item }
    end
  end
end

