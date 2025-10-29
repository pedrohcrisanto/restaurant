# frozen_string_literal: true

module Menus
  class Create < Micro::Case
    include UseCaseHelpers

    attributes :restaurant, :params, :repo

    def call!
      # Guard clauses: validate inputs
      return failure_not_found(:restaurant) unless restaurant
      return failure_missing_params unless params

      menu = build_menu
      return failure_validation(menu) unless save_menu(menu)

      Success result: { menu: menu }
    rescue StandardError => e
      handle_error(e, "menus.create", restaurant_id: restaurant&.id, params: params)
    end

    private

    def build_menu
      repo ? repo.build_for(restaurant, params) : restaurant.menus.new(params)
    end

    def save_menu(menu)
      save_with_repo(repo, menu)
    end
  end
end
