# frozen_string_literal: true

module NestedResource
  extend ActiveSupport::Concern

  included do
    before_action :load_parent_restaurant, if: -> { params[:restaurant_id].present? }
  end

  private

  def load_parent_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end
end
