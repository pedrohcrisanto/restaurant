# frozen_string_literal: true

module Menus
  class EnsureExistsForRestaurant < Micro::Case
    attributes :restaurant, :name

    def call!
      normalized_name = name.to_s.strip
      menu = restaurant.menus.where('LOWER(name) = ?', normalized_name.downcase).first
      if menu.nil?
        menu = restaurant.menus.create!(name: normalized_name)
        action = :created_menu
      else
        action = :existing_menu
      end

      Success result: { menu:, action: }
    rescue ActiveRecord::RecordInvalid => e
      Failure :invalid, result: { error: e.record.errors.full_messages }
    end
  end
end

