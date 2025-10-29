# frozen_string_literal: true

module Restaurants
  class Destroy < Micro::Case
    attributes :repo, :restaurant

    def call!
      return Failure(:not_found, result: { error: I18n.t('errors.restaurants.not_found') }) if restaurant.nil?

      repo.destroy(restaurant)
      Success result: { destroyed: true }
    end
  end
end

