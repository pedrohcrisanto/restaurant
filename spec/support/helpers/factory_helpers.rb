# frozen_string_literal: true

# Factory helpers for easier test data creation
# Following FactoryBot best practices
module FactoryHelpers
  # Create a restaurant with full menu structure
  def create_full_restaurant(name: nil, menus_count: 2, items_per_menu: 3)
    restaurant = create(:restaurant, name: name || "Test Restaurant")

    menus_count.times do |i|
      menu = create(:menu, restaurant: restaurant, name: "Menu #{i + 1}")

      items_per_menu.times do
        menu_item = create(:menu_item)
        create(:menu_item_placement, menu: menu, menu_item: menu_item)
      end
    end

    restaurant.reload
  end

  # Create a menu with items
  def create_menu_with_items(restaurant: nil, items_count: 5, **menu_attrs)
    restaurant ||= create(:restaurant)
    menu = create(:menu, restaurant: restaurant, **menu_attrs)

    items_count.times do
      menu_item = create(:menu_item)
      create(:menu_item_placement, menu: menu, menu_item: menu_item)
    end

    menu.reload
  end

  # Create menu items with different price ranges
  def create_menu_items_with_prices(menu, cheap: 1, moderate: 1, expensive: 1)
    items = []

    cheap.times do
      menu_item = create(:menu_item)
      items << create(:menu_item_placement, :cheap, menu: menu, menu_item: menu_item)
    end

    moderate.times do
      menu_item = create(:menu_item)
      items << create(:menu_item_placement, :moderate, menu: menu, menu_item: menu_item)
    end

    expensive.times do
      menu_item = create(:menu_item)
      items << create(:menu_item_placement, :expensive, menu: menu, menu_item: menu_item)
    end

    items
  end

  # Build attributes for API requests
  def restaurant_attributes(overrides = {})
    attributes_for(:restaurant).merge(overrides)
  end

  def menu_attributes(overrides = {})
    attributes_for(:menu).except(:restaurant, :restaurant_id).merge(overrides)
  end

  def menu_item_attributes(overrides = {})
    attributes_for(:menu_item).merge(overrides)
  end

  # Create test data for pagination
  def create_paginated_restaurants(count: 25)
    create_list(:restaurant, count)
  end

  # Create restaurants with specific names for search testing
  def create_searchable_restaurants
    {
      italian: create(:restaurant, name: "Italian Bistro"),
      mexican: create(:restaurant, name: "Mexican Cantina"),
      japanese: create(:restaurant, name: "Japanese Sushi Bar"),
      american: create(:restaurant, name: "American Diner"),
    }
  end
end

RSpec.configure do |config|
  config.include FactoryHelpers
end

