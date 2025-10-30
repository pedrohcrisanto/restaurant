# frozen_string_literal: true

module Repositories
  module Persistence
    class RestaurantsRepository
      BATCH_SIZE = 1000

      # Returns an AR::Relation optimized for listing with eager loading
      def relation_for_index
        ::Restaurant.eager_load(menus: { menu_item_placements: :menu_item }).ordered
      end

      def find(id)
        ::Restaurant.with_full_associations.find(id)
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
        # Ensure we raise RecordNotFound if the record does not exist
        found = ::Restaurant.find(record.id)
        found.destroy
      end

      # Bulk operations for performance with large datasets
      def bulk_insert(records_attrs, unique_by: nil)
        return [] if records_attrs.empty?

        options = { returning: %i[id name] }
        options[:unique_by] = unique_by if unique_by

        # rubocop:disable Rails/SkipsModelValidations
        ::Restaurant.insert_all(records_attrs, **options)
        # rubocop:enable Rails/SkipsModelValidations
      end

      def bulk_update(records_data)
        return 0 if records_data.empty?

        updated_count = 0
        records_data.each_slice(BATCH_SIZE) do |batch|
          batch.each do |data|
            id = data.delete(:id)
            # rubocop:disable Rails/SkipsModelValidations
            ::Restaurant.where(id: id).update_all(data)
            # rubocop:enable Rails/SkipsModelValidations
            updated_count += 1
          end
        end
        updated_count
      end

      def exists_by_name?(name)
        ::Restaurant.by_name_ci(name).exists?
      end

      def find_by_name(name)
        ::Restaurant.by_name_ci(name).first
      end
    end
  end
end
