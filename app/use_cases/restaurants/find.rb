# frozen_string_literal: true

module Restaurants
  class Find < Micro::Case
    attributes :repo, :id

    def call!
      restaurant = repo.find(id)
      return Failure(:not_found, result: { error: I18n.t('errors.restaurants.not_found') }) if restaurant.nil?

      Success result: { restaurant: restaurant }
    end
  end
end

