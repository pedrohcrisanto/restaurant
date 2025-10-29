# frozen_string_literal: true

module MenuItems
  class EnsureExistsByName < Micro::Case
    attribute :name

    def call!
      normalized_name = normalize(name)

      item = MenuItem.where('LOWER(name) = ?', normalized_name.downcase).first

      action = nil
      if item.nil?
        item = MenuItem.new(name: normalized_name)
        action = :created_item
      else
        action = :unchanged_item
        # Normalize existing record name
        if item.name.to_s != normalized_name
          item.name = normalized_name
          action = :updated_item
        end
      end

      item.save! if item.changed?

      Success result: { menu_item: item, action: action }
    rescue ActiveRecord::RecordInvalid => e
      Failure :invalid, result: { error: e.record.errors.full_messages }
    end

    private

    def normalize(value)
      value.to_s.strip.squeeze(' ')
    end
  end
end

