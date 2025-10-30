# frozen_string_literal: true

module NestedResource
  extend ActiveSupport::Concern

  included do
    before_action :load_parent_restaurant, if: -> { params[:restaurant_id].present? }
  end

  private

  def load_parent_restaurant
    @restaurant = Restaurant.find_by(id: params[:restaurant_id])
    return if @restaurant

    # Render a 404 with the standard i18n error when parent restaurant isn't found
    render_not_found("errors.restaurants.not_found")
  end
end
