# frozen_string_literal: true

module Menus
  class FindOrCreate < Micro::Case
    include UseCaseHelpers

    attributes :restaurant, :name

    def call!
      # Guard clauses: validate inputs
      return failure_not_found(:restaurant) unless restaurant
      return failure_missing_name unless valid_name?(name)

      menu, action = find_or_create_menu
      Success result: { menu: menu, action: action }
    rescue ActiveRecord::RecordInvalid => e
      failure_validation(e)
    rescue StandardError => e
      handle_error(e, "menus.find_or_create", restaurant_id: restaurant&.id, name: name)
    end

    private

    def find_or_create_menu
      normalized = normalize_name(name)
      menu = find_existing_menu(normalized)

      return [menu, :found] if menu

      [create_menu(normalized), :created]
    end

    def find_existing_menu(normalized)
      restaurant.menus.by_name_ci(normalized).first
    end

    def create_menu(normalized)
      restaurant.menus.create!(name: normalized)
    end
  end
end
