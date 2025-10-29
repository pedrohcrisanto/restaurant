# frozen_string_literal: true

module MenuItems
  class FindOrCreate < Micro::Case
    include UseCaseHelpers

    attribute :name

    def call!
      # Guard clause: validate name presence
      return failure_missing_name unless valid_name?(name)

      normalized = normalize_name(name)
      item, action = find_or_create_item(normalized)

      Success result: { menu_item: item, action: action }
    rescue ActiveRecord::RecordInvalid => e
      failure_validation(e)
    rescue StandardError => e
      handle_error(e, "menu_items.find_or_create", name: name)
    end

    private

    def find_or_create_item(normalized)
      item = find_existing_item(normalized)

      return create_new_item(normalized) unless item
      return update_existing_item(item, normalized) if needs_normalization?(item, normalized)

      [item, :unchanged]
    end

    def find_existing_item(normalized)
      MenuItem.by_name_ci(normalized).first
    end

    def create_new_item(normalized)
      item = MenuItem.new(name: normalized)
      item.save!
      [item, :created]
    end

    def needs_normalization?(item, normalized)
      item.name.to_s != normalized
    end

    def update_existing_item(item, normalized)
      item.name = normalized
      item.save!
      [item, :updated]
    end
  end
end
