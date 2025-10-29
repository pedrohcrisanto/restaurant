# frozen_string_literal: true

module Menus
  class Create < Micro::Case
    attributes :restaurant, :params, :repo

    def call!
      return Failure(:invalid, result: { error: I18n.t('errors.restaurants.not_found') }) if restaurant.nil?

      menu = if repo
                repo.build_for_restaurant(restaurant, params)
              else
                restaurant.menus.new(params)
              end

      if (repo ? repo.save(menu) : menu.save)
        Success result: { menu: menu }
      else
        Failure :invalid, result: { error: menu.errors.full_messages }
      end
    end
  end
end

