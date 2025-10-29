# frozen_string_literal: true

module Repositories
  module ActiveRecord
    class MenuItemsRepository
      # Returns an AR::Relation of menu items for a restaurant (distinct)
      def relation_for_restaurant(restaurant)
        ::MenuItem
          .joins(:menus)
          .where(menus: { restaurant_id: restaurant.id })
          .distinct
          .order(:id)
      end

      def find_for_restaurant(restaurant, id)
        ::MenuItem
          .joins(:menus)
          .where(menus: { restaurant_id: restaurant.id })
          .distinct
          .find_by(id: id)
      end

      def build(attrs = {})
        ::MenuItem.new(attrs)
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

