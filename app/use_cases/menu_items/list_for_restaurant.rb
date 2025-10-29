# frozen_string_literal: true

module MenuItems
  class ListForRestaurant < Micro::Case
    attributes :restaurant, :repo

    def call!
      return Failure(:invalid, result: { error: I18n.t('errors.restaurants.not_found') }) if restaurant.nil?

      items = if repo
                  repo.relation_for_restaurant(restaurant)
                else
                  MenuItem
                    .joins(:menus)
                    .where(menus: { restaurant_id: restaurant.id })
                    .distinct
                    .order(:id)
                end

      Success result: { items: items }
    end
  end
end

