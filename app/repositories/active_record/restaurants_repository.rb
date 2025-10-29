# frozen_string_literal: true

module Repositories
  module ActiveRecord
    class RestaurantsRepository
      # Returns an AR::Relation optimized for listing
      def relation_for_index
        ::Restaurant
          .includes(menus: { menu_item_placements: :menu_item })
          .order(:id)
      end

      def find(id)
        ::Restaurant
          .includes(menus: { menu_item_placements: :menu_item })
          .find_by(id: id)
      end

      def build(attrs = {})
        ::Restaurant.new(attrs)
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

