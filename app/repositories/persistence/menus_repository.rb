# frozen_string_literal: true

module Persistence
  class MenusRepository
    BATCH_SIZE = 1000

      # Returns an AR::Relation of menus for a restaurant optimized for listing
      def for_restaurant(restaurant)
        restaurant.menus.with_items.ordered
      end

      def find_by_restaurant(restaurant, id)
        # Use `find` scoped through the association to ensure it belongs to the restaurant
        # and to raise ActiveRecord::RecordNotFound when id is nil or not found.
        restaurant.menus.with_items.find(id)
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

        # rubocop:disable Rails/SkipsModelValidations
        ::Menu.insert_all(records_attrs, **options)
        # rubocop:enable Rails/SkipsModelValidations
      end

      def bulk_update(records_data)
        return 0 if records_data.empty?

        updated_count = 0
        records_data.each_slice(BATCH_SIZE) do |batch|
          batch.each do |data|
            id = data.delete(:id)
            # rubocop:disable Rails/SkipsModelValidations
            ::Menu.where(id: id).update_all(data)
            # rubocop:enable Rails/SkipsModelValidations
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
