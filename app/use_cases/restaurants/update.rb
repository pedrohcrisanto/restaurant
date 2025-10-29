# frozen_string_literal: true

module Restaurants
  class Update < Micro::Case
    attributes :repo, :restaurant, :params

    def call!
      return Failure(:not_found, result: { error: I18n.t('errors.restaurants.not_found') }) if restaurant.nil?

      if repo.update(restaurant, params)
        Success result: { restaurant: restaurant }
      else
        Failure :invalid, result: { error: restaurant.errors.full_messages }
      end
    end
  end
end

