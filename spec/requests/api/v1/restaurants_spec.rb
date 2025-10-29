# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Api::V1::Restaurants", type: :request do
  let(:json) { JSON.parse(response.body) }

  path "/api/v1/restaurants" do
    get "List all restaurants" do
      tags "Restaurants"
      produces "application/json"
      parameter name: :page, in: :query, type: :integer, required: false, description: "Page number"
      parameter name: :per_page, in: :query, type: :integer, required: false, description: "Items per page"

      response "200", "restaurants found" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string },
                       menus: { type: :array }
                     },
                     required: %w[id name menus]
                   }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     current_page: { type: :integer },
                     total_pages: { type: :integer },
                     total_count: { type: :integer }
                   }
                 }
               },
               required: %w[data meta]

        let!(:restaurants) { create_list(:restaurant, 3) }

        run_test! do |response|
          expect(json["data"]).to be_an(Array)
          expect(json["data"].size).to eq(3)
          expect(json["meta"]).to have_key("current_page")
        end
      end

      response "200", "empty list when no restaurants" do
        run_test! do |response|
          expect(json["data"]).to eq([])
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
          expect(json["data"]["name"]).to eq("New Restaurant")
          expect(json["data"]["id"]).to be_present
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
          expect(json["error"]).to include(/already been taken/i)
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
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string },
                     menus: { type: :array }
                   },
                   required: %w[id name menus]
                 }
               },
               required: %w[data]

        let(:id) { create(:restaurant).id }

        run_test! do |response|
          expect(json["data"]["id"]).to eq(id)
          expect(json["data"]["name"]).to be_present
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
          expect(json["data"]["name"]).to eq("Updated Name")
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
