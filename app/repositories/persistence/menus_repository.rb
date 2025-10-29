# frozen_string_literal: true

module Repositories
  module Persistence
    class MenusRepository
      BATCH_SIZE = 1000

      # Returns an AR::Relation of menus for a restaurant optimized for listing
      def for_restaurant(restaurant)
        restaurant.menus.with_items.ordered
      end

      def find_by_restaurant(restaurant, id)
        restaurant.menus.with_items.find_by(id: id)
      end

      def build_for(restaurant, attrs = {})
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

      # Bulk operations for performance with large datasets
      def bulk_insert(records_attrs, unique_by: nil)
        return [] if records_attrs.empty?

        options = { returning: %i[id name restaurant_id] }
        options[:unique_by] = unique_by if unique_by

        ::Menu.insert_all(records_attrs, **options)
      end

      def bulk_update(records_data)
        return 0 if records_data.empty?

        updated_count = 0
        records_data.each_slice(BATCH_SIZE) do |batch|
          batch.each do |data|
            id = data.delete(:id)
            ::Menu.where(id: id).update_all(data)
            updated_count += 1
          end
        end
        updated_count
      end

      def find_by_restaurant_and_name(restaurant, name)
        restaurant.menus.by_name_ci(name).first
      end
    end
  end
end
