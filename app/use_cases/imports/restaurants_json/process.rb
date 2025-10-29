# frozen_string_literal: true
require 'json'


module Imports
  module RestaurantsJson
    class Process < Micro::Case
      attribute :json

      def call!
        data = parse_json(json)
        logs = []

        ActiveRecord::Base.transaction do
          Array(data['restaurants']).each do |res|
            restaurant_name = res['name'] || res[:name]
            restaurant = Restaurant.where('LOWER(name) = ?', restaurant_name.to_s.downcase).first_or_create!(name: restaurant_name)
            logs << log_entry(nil, :created_restaurant, restaurant: restaurant.name) if restaurant.previous_changes.present?

            Array(res['menus'] || res[:menus]).each do |menu_hash|
              menu_name = menu_hash['name'] || menu_hash[:name]
              menu_result = Menus::EnsureExistsForRestaurant.call(restaurant:, name: menu_name)
              if menu_result.failure?
                logs << log_entry(nil, :menu_error, restaurant: restaurant.name, menu: menu_name, error: menu_result[:error])
                next
              end
              menu = menu_result[:menu]
              logs << log_entry(nil, :created_menu, restaurant: restaurant.name, menu: menu.name) if menu_result[:action] == :created_menu

              items_array = Array(menu_hash['menu_items'] || menu_hash[:menu_items] || menu_hash['dishes'] || menu_hash[:dishes])
              items_array.each do |item_hash|
                item_name = item_hash['name'] || item_hash[:name]
                price = item_hash['price'] || item_hash[:price]
                upsert_result = MenuItems::EnsureExistsByName.call(name: item_name)
                if upsert_result.failure?
                  logs << log_entry(item_name, :item_error, restaurant: restaurant.name, menu: menu.name, error: upsert_result[:error])
                  next
                end

                menu_item = upsert_result[:menu_item]
                action = upsert_result[:action]

                begin
                  placement = MenuItemPlacement.find_or_initialize_by(menu:, menu_item:)
                  link_action = placement.new_record? ? :linked_item : :existing_link
                  # Set/Update price from payload when provided
                  if !price.nil?
                    placement.price = price
                  end
                  placement.save! if placement.changed?
                rescue ActiveRecord::RecordInvalid => e
                  logs << log_entry(menu_item.name, :link_error, restaurant: restaurant.name, menu: menu.name, error: e.record.errors.full_messages)
                  next
                end

                logs << log_entry(menu_item.name, action, restaurant: restaurant.name, menu: menu.name, price: placement.price)
                logs << log_entry(menu_item.name, link_action, restaurant: restaurant.name, menu: menu.name)
              end
            end
          end
        end

        Success result: { success: true, logs: logs }
      rescue JSON::ParserError => e
        Failure :invalid_json, result: { success: false, logs: [log_entry(nil, :invalid_json, error: e.message)] }
      end

      private

      def parse_json(content)
        case content
        when String
          JSON.parse(content)
        else
          JSON.parse(content.to_s)
        end
      end

      def log_entry(item_name, action, restaurant: nil, menu: nil, price: nil, error: nil)
        {
          restaurant: restaurant,
          menu: menu,
          item: item_name,
          action: action.to_s,
          price: price,
          error: error
        }.compact
      end
    end
  end
end

