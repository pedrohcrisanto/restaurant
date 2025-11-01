# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Api::V1::Restaurants", type: :request do
  let(:json) { JSON.parse(response.body) }

  path "/api/v1/restaurants" do
    # Ensure a clean slate for each example in this path to avoid cross-spec contamination (e.g., imports pagination)
    before do
      MenuItemPlacement.delete_all
      Menu.delete_all
      Restaurant.delete_all
    end

    get "List all restaurants" do
      tags "Restaurants"
      produces "application/json"
      parameter name: :page, in: :query, type: :integer, required: false, description: "Page number"
      parameter name: :per_page, in: :query, type: :integer, required: false, description: "Items per page"

      response "200", "restaurants found" do
        schema "$ref" => "#/components/schemas/restaurant_list"
        header "X-Current-Page", schema: { type: :string }
        header "X-Per-Page", schema: { type: :string }
        header "X-Total", schema: { type: :string }
        header "X-Total-Pages", schema: { type: :string }

        let!(:restaurants) { create_list(:restaurant, 3) }

        run_test! do |response|
          expect(json).to be_an(Array)
          expect(json.size).to eq(3)
          expect(response.headers).to include("X-Current-Page", "X-Per-Page", "X-Total", "X-Total-Pages")
        end
      end

      response "200", "empty list when no restaurants" do
        run_test! do |response|
          expect(json).to eq([])
        end
      end
    end

    post "Create a restaurant" do
      tags "Restaurants"
      consumes "application/json"
      produces "application/json"
      parameter name: :restaurant, in: :body, schema: {
        type: :object,
        properties: {
          restaurant: {
            type: :object,
            properties: {
              name: { type: :string }
            },
            required: %w[name]
          }
        },
        required: %w[restaurant]
      }

      response "201", "restaurant created" do
        let(:restaurant) { { restaurant: { name: "New Restaurant" } } }

        run_test! do |response|
          expect(json["name"]).to eq("New Restaurant")
          expect(json["id"]).to be_present
        end
      end

      response "422", "invalid request - blank name" do
        let(:restaurant) { { restaurant: { name: "" } } }

        run_test! do |response|
          expect(json["error"]).to be_present
        end
      end

      response "422", "invalid request - duplicate name" do
        let!(:existing) { create(:restaurant, name: "Existing") }
        let(:restaurant) { { restaurant: { name: "Existing" } } }

        run_test! do |response|
          expect(json.dig("error", "message")).to match(/already been taken/i)
        end
      end
    end
  end

  path "/api/v1/restaurants/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Restaurant ID"

    get "Show a restaurant" do
      tags "Restaurants"
      produces "application/json"

      response "200", "restaurant found" do
        schema "$ref" => "#/components/schemas/restaurant"

        let(:id) { create(:restaurant).id }

        run_test! do |response|
          expect(json["id"]).to eq(id)
          expect(json["name"]).to be_present
        end
      end

      response "404", "restaurant not found" do
        let(:id) { 999_999 }

        run_test! do |response|
          expect(json["error"]).to be_present
        end
      end
    end

    put "Update a restaurant" do
      tags "Restaurants"
      consumes "application/json"
      produces "application/json"
      parameter name: :restaurant, in: :body, schema: {
        type: :object,
        properties: {
          restaurant: {
            type: :object,
            properties: {
              name: { type: :string }
            }
          }
        }
      }

      response "200", "restaurant updated" do
        let(:id) { create(:restaurant, name: "Original").id }
        let(:restaurant) { { restaurant: { name: "Updated Name" } } }

        run_test! do |response|
          expect(json["name"]).to eq("Updated Name")
        end
      end

      response "404", "restaurant not found" do
        let(:id) { 999_999 }
        let(:restaurant) { { restaurant: { name: "Updated" } } }

        run_test! do |response|
          expect(json["error"]).to be_present
        end
      end

      response "422", "invalid request - blank name" do
        let(:id) { create(:restaurant).id }
        let(:restaurant) { { restaurant: { name: "" } } }

        run_test! do |response|
          expect(json["error"]).to be_present
        end
      end
    end

    delete "Delete a restaurant" do
      tags "Restaurants"
      produces "application/json"

      response "204", "restaurant deleted" do
        let(:id) { create(:restaurant).id }

        run_test! do |response|
          expect(response.body).to be_empty
          expect(Restaurant.exists?(id)).to be false
        end
      end

      response "404", "restaurant not found" do
        let(:id) { 999_999 }

        run_test! do |response|
          expect(json["error"]).to be_present
        end
      end
    end
  end
end
