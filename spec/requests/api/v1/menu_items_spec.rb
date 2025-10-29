# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Api::V1::MenuItems", type: :request do
  let(:json) { JSON.parse(response.body) }
  let(:restaurant) { create(:restaurant) }

  path "/api/v1/restaurants/{restaurant_id}/menu_items" do
    parameter name: :restaurant_id, in: :path, type: :integer, description: "Restaurant ID"

    get "List menu items for a restaurant" do
      tags "MenuItems"
      produces "application/json"

      response "200", "menu items found" do
        schema "$ref" => "#/components/schemas/menu_item_list"
        header "X-Current-Page", schema: { type: :string }
        header "X-Per-Page", schema: { type: :string }
        header "X-Total", schema: { type: :string }
        header "X-Total-Pages", schema: { type: :string }

        let(:restaurant_id) { restaurant.id }

        before do
          menu = create(:menu, restaurant: restaurant)
          create_list(:menu_item, 2).each do |item|
            create(:menu_item_placement, menu: menu, menu_item: item)
          end
        end

        run_test! do |response|
          expect(json).to be_an(Array)
          expect(json.size).to eq(2)
          expect(response.headers).to include("X-Current-Page", "X-Per-Page", "X-Total", "X-Total-Pages")
        end
      end

      response "404", "restaurant not found" do
        let(:restaurant_id) { 999_999 }

        run_test! do |response|
          expect(json["error"]).to be_present
        end
      end
    end

    post "Create a menu item" do
      tags "MenuItems"
      consumes "application/json"
      produces "application/json"
      parameter name: :menu_item, in: :body, schema: {
        type: :object,
        properties: {
          menu_item: {
            type: :object,
            properties: {
              name: { type: :string }
            },
            required: %w[name]
          }
        },
        required: %w[menu_item]
      }

      response "201", "menu item created" do
        let(:restaurant_id) { restaurant.id }
        let(:menu_item) { { menu_item: { name: "Caesar Salad" } } }

        run_test! do |response|
          expect(json["name"]).to eq("Caesar Salad")
          expect(json["id"]).to be_present
        end
      end

      response "422", "invalid request - blank name" do
        let(:restaurant_id) { restaurant.id }
        let(:menu_item) { { menu_item: { name: "" } } }

        run_test! do |response|
          expect(json["error"]).to be_present
        end
      end
    end
  end

  path "/api/v1/restaurants/{restaurant_id}/menu_items/{id}" do
    parameter name: :restaurant_id, in: :path, type: :integer, description: "Restaurant ID"
    parameter name: :id, in: :path, type: :integer, description: "Menu Item ID"

    get "Show a menu item" do
      tags "MenuItems"
      produces "application/json"

      response "200", "menu item found" do
        let(:restaurant_id) { restaurant.id }
        let(:menu) { create(:menu, restaurant: restaurant) }
        let(:menu_item_record) { create(:menu_item) }
        let(:id) { menu_item_record.id }

        before { create(:menu_item_placement, menu: menu, menu_item: menu_item_record) }

        run_test! do |response|
          expect(json["id"]).to eq(id)
          expect(json["name"]).to be_present
        end
      end

      response "404", "menu item not found for restaurant" do
        let(:restaurant_id) { restaurant.id }
        let(:id) { create(:menu_item).id }

        run_test! do |response|
          expect(json["error"]).to be_present
        end
      end
    end

    put "Update a menu item" do
      tags "MenuItems"
      consumes "application/json"
      produces "application/json"
      parameter name: :menu_item, in: :body, schema: {
        type: :object,
        properties: {
          menu_item: {
            type: :object,
            properties: {
              name: { type: :string }
            }
          }
        }
      }

      response "200", "menu item updated" do
        let(:restaurant_id) { restaurant.id }
        let(:menu) { create(:menu, restaurant: restaurant) }
        let(:menu_item_record) { create(:menu_item, name: "Original") }
        let(:id) { menu_item_record.id }
        let(:menu_item) { { menu_item: { name: "Updated Item" } } }

        before { create(:menu_item_placement, menu: menu, menu_item: menu_item_record) }

        run_test! do |response|
          expect(json["name"]).to eq("Updated Item")
        end
      end

      response "404", "menu item not found" do
        let(:restaurant_id) { restaurant.id }
        let(:id) { 999_999 }
        let(:menu_item) { { menu_item: { name: "Updated" } } }

        run_test! do |response|
          expect(json["error"]).to be_present
        end
      end
    end

    delete "Delete a menu item" do
      tags "MenuItems"
      produces "application/json"

      response "204", "menu item deleted" do
        let(:restaurant_id) { restaurant.id }
        let(:menu) { create(:menu, restaurant: restaurant) }
        let(:menu_item_record) { create(:menu_item) }
        let(:id) { menu_item_record.id }

        before { create(:menu_item_placement, menu: menu, menu_item: menu_item_record) }

        run_test! do |response|
          expect(response.body).to be_empty
          expect(MenuItem.exists?(id)).to be false
        end
      end

      response "404", "menu item not found" do
        let(:restaurant_id) { restaurant.id }
        let(:id) { 999_999 }

        run_test! do |response|
          expect(json["error"]).to be_present
        end
      end
    end
  end
end
