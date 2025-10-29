# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Api::V1::Menus", type: :request do
  let(:json) { JSON.parse(response.body) }
  let(:restaurant) { create(:restaurant) }

  path "/api/v1/restaurants/{restaurant_id}/menus" do
    parameter name: :restaurant_id, in: :path, type: :integer, description: "Restaurant ID"

    get "List menus for a restaurant" do
      tags "Menus"
      produces "application/json"

      response "200", "menus found" do
        let(:restaurant_id) { restaurant.id }
        let!(:menus) { create_list(:menu, 2, restaurant: restaurant) }

        run_test! do |response|
          expect(json["data"]).to be_an(Array)
          expect(json["data"].size).to eq(2)
        end
      end

      response "404", "restaurant not found" do
        let(:restaurant_id) { 999_999 }

        run_test! do |response|
          expect(json["error"]).to be_present
        end
      end
    end

    post "Create a menu for a restaurant" do
      tags "Menus"
      consumes "application/json"
      produces "application/json"
      parameter name: :menu, in: :body, schema: {
        type: :object,
        properties: {
          menu: {
            type: :object,
            properties: {
              name: { type: :string }
            },
            required: %w[name]
          }
        }
      }

      response "201", "menu created" do
        let(:restaurant_id) { restaurant.id }
        let(:menu) { { menu: { name: "Lunch Menu" } } }

        run_test! do |response|
          expect(json["data"]["name"]).to eq("Lunch Menu")
          expect(json["data"]["id"]).to be_present
        end
      end

      response "422", "invalid request - blank name" do
        let(:restaurant_id) { restaurant.id }
        let(:menu) { { menu: { name: "" } } }

        run_test! do |response|
          expect(json["error"]).to be_present
        end
      end

      response "404", "restaurant not found" do
        let(:restaurant_id) { 999_999 }
        let(:menu) { { menu: { name: "Test" } } }

        run_test! do |response|
          expect(json["error"]).to be_present
        end
      end
    end
  end

  path "/api/v1/restaurants/{restaurant_id}/menus/{id}" do
    parameter name: :restaurant_id, in: :path, type: :integer, description: "Restaurant ID"
    parameter name: :id, in: :path, type: :integer, description: "Menu ID"

    get "Show a menu" do
      tags "Menus"
      produces "application/json"

      response "200", "menu found" do
        let(:restaurant_id) { restaurant.id }
        let(:menu_record) { create(:menu, restaurant: restaurant) }
        let(:id) { menu_record.id }

        run_test! do |response|
          expect(json["data"]["id"]).to eq(id)
          expect(json["data"]["name"]).to be_present
        end
      end

      response "404", "menu not found" do
        let(:restaurant_id) { restaurant.id }
        let(:id) { 999_999 }

        run_test! do |response|
          expect(json["error"]).to be_present
        end
      end

      response "404", "menu belongs to another restaurant" do
        let(:other_restaurant) { create(:restaurant) }
        let(:other_menu) { create(:menu, restaurant: other_restaurant) }
        let(:restaurant_id) { restaurant.id }
        let(:id) { other_menu.id }

        run_test! do |response|
          expect(json["error"]).to be_present
        end
      end
    end

    put "Update a menu" do
      tags "Menus"
      consumes "application/json"
      produces "application/json"
      parameter name: :menu, in: :body, schema: {
        type: :object,
        properties: {
          menu: {
            type: :object,
            properties: {
              name: { type: :string }
            }
          }
        }
      }

      response "200", "menu updated" do
        let(:restaurant_id) { restaurant.id }
        let(:menu_record) { create(:menu, restaurant: restaurant, name: "Original") }
        let(:id) { menu_record.id }
        let(:menu) { { menu: { name: "Updated Menu" } } }

        run_test! do |response|
          expect(json["data"]["name"]).to eq("Updated Menu")
        end
      end

      response "404", "menu not found" do
        let(:restaurant_id) { restaurant.id }
        let(:id) { 999_999 }
        let(:menu) { { menu: { name: "Updated" } } }

        run_test! do |response|
          expect(json["error"]).to be_present
        end
      end
    end

    delete "Delete a menu" do
      tags "Menus"
      produces "application/json"

      response "204", "menu deleted" do
        let(:restaurant_id) { restaurant.id }
        let(:menu_record) { create(:menu, restaurant: restaurant) }
        let(:id) { menu_record.id }

        run_test! do |response|
          expect(response.body).to be_empty
          expect(Menu.exists?(id)).to be false
        end
      end

      response "404", "menu not found" do
        let(:restaurant_id) { restaurant.id }
        let(:id) { 999_999 }

        run_test! do |response|
          expect(json["error"]).to be_present
        end
      end
    end
  end
end
