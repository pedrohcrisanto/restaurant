# frozen_string_literal: true

require "json"

module Imports
  module RestaurantsJson
    # rubocop:disable Metrics/ClassLength
    class Process < Micro::Case
      attribute :json

      def call!
        data = parse_json(json)
        logs = import_restaurants(data)

        Success result: { success: true, logs: logs }
      rescue JSON::ParserError => e
        Failure :invalid_json, result: { success: false, logs: [log_entry(nil, :invalid_json, error: e.message)] }
      end

      private

      def import_restaurants(data)
        logs = []

        ActiveRecord::Base.transaction do
          Array(data["restaurants"]).each do |restaurant_data|
            logs.concat(process_restaurant(restaurant_data))
          end
        end

        logs
      end

      def process_restaurant(restaurant_data)
        logs = []
        restaurant = find_or_create_restaurant(extract_name(restaurant_data))
        logs << log_created_restaurant(restaurant) if restaurant.previous_changes.present?

        Array(restaurant_data["menus"] || restaurant_data[:menus]).each do |menu_data|
          logs.concat(process_menu(restaurant, menu_data))
        end

        logs
      end

      def process_menu(restaurant, menu_data)
        logs = []
        menu_name = extract_name(menu_data)
        menu_result = Menus::FindOrCreate.call(restaurant: restaurant, name: menu_name)

        return logs << log_menu_error(restaurant, menu_name, menu_result[:error]) if menu_result.failure?

        menu = menu_result[:menu]
        logs << log_created_menu(restaurant, menu) if menu_result[:action] == :created

        items_data = extract_menu_items(menu_data)
        items_data.each { |item_data| logs.concat(process_menu_item(restaurant, menu, item_data)) }

        logs
      end

      def process_menu_item(restaurant, menu, item_data)
        item_name = extract_name(item_data)
        price = extract_price(item_data)

        upsert_result = MenuItems::FindOrCreate.call(name: item_name)
        return [log_item_error(restaurant, menu, item_name, upsert_result[:error])] if upsert_result.failure?

        menu_item = upsert_result[:menu_item]
        placement_result = link_menu_item(menu, menu_item, price)
        return [log_link_error(restaurant, menu, menu_item, placement_result[:error])] if placement_result[:error]

        build_success_logs(restaurant, menu, menu_item, upsert_result[:action], placement_result[:action], placement_result[:price])
      end

      def build_success_logs(restaurant, menu, menu_item, create_action, link_action, price)
        [
          log_entry(menu_item.name, create_action, restaurant: restaurant.name, menu: menu.name, price: price),
          log_entry(menu_item.name, link_action, restaurant: restaurant.name, menu: menu.name)
        ]
      end

      def find_or_create_restaurant(name)
        Restaurant.where("LOWER(name) = ?", name.to_s.downcase).first_or_create!(name: name)
      end

      def link_menu_item(menu, menu_item, price)
        placement = MenuItemPlacement.find_or_initialize_by(menu: menu, menu_item: menu_item)
        action = placement.new_record? ? :linked : :found
        placement.price = price unless price.nil?
        placement.save! if placement.changed?

        { action: action, price: placement.price, error: nil }
      rescue ActiveRecord::RecordInvalid => e
        { action: nil, price: nil, error: e.record.errors.full_messages }
      end

      def extract_name(data)
        data.values_at("name", :name).compact.first
      end

      def extract_menu_items(menu_data)
        menu_data.values_at("menu_items", :menu_items, "dishes", :dishes).compact.first || []
      end

      def extract_price(data)
        data.values_at("price", :price).compact.first
      end

      def parse_json(content)
        JSON.parse(content.is_a?(String) ? content : content.to_s)
      end

      def log_created_restaurant(restaurant)
        log_entry(nil, :created_restaurant, restaurant: restaurant.name)
      end

      def log_created_menu(restaurant, menu)
        log_entry(nil, :created_menu, restaurant: restaurant.name, menu: menu.name)
      end

      def log_menu_error(restaurant, menu_name, error)
        log_entry(nil, :menu_error, restaurant: restaurant.name, menu: menu_name, error: error)
      end

      def log_item_error(restaurant, menu, item_name, error)
        log_entry(item_name, :item_error, restaurant: restaurant.name, menu: menu.name, error: error)
      end

      def log_link_error(restaurant, menu, menu_item, error)
        log_entry(menu_item.name, :link_error, restaurant: restaurant.name, menu: menu.name, error: error)
      end

      # rubocop:disable Metrics/ParameterLists
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
      # rubocop:enable Metrics/ParameterLists
    end
    # rubocop:enable Metrics/ClassLength
  end
end
