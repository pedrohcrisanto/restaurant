# frozen_string_literal: true

module Repositories
  module ActiveRecord
    class MenusRepository
      # Returns an AR::Relation of menus for a restaurant optimized for listing
      def relation_for_restaurant(restaurant)
        restaurant
          .menus
          .includes(menu_item_placements: :menu_item)
          .order(:id)
      end

      def find_for_restaurant(restaurant, id)
        restaurant
          .menus
          .includes(menu_item_placements: :menu_item)
          .find_by(id: id)
      end

      def build_for_restaurant(restaurant, attrs = {})
        restaurant.menus.new(attrs)
      end

      def save(record)
        record.save
      end

      def update(record, attrs)
        record.update(attrs)
      end

      def destroy(record)
        record.destroy
      end
    end
  end
end

