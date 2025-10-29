# frozen_string_literal: true

require "rails_helper"

# Contract tests for Menu API endpoints
RSpec.describe "Menu API Contract", type: :request do
  let(:restaurant) { create(:restaurant) }
  let(:menu) { create(:menu, restaurant: restaurant) }

  describe "GET /api/v1/restaurants/:restaurant_id/menus" do
    it "returns response matching the schema" do
      create_list(:menu, 3, restaurant: restaurant)

      get "/api/v1/restaurants/#{restaurant.id}/menus"

      expect(response).to have_http_status(:ok)
      expect(response).to have_content_type_json

      json = JSON.parse(response.body)
      expect(json).to be_an(Array)

      json.each do |menu_data|
        expect(menu_data).to match_json_schema(
          id: :integer,
          name: :string,
          items: :array
        )
      end
    end
  end

  describe "GET /api/v1/restaurants/:restaurant_id/menus/:id" do
    it "returns response matching the schema" do
      get "/api/v1/restaurants/#{restaurant.id}/menus/#{menu.id}"

      expect(response).to have_http_status(:ok)
      expect(response).to have_content_type_json

      json = JSON.parse(response.body)
      expect(json).to match_json_schema(
        id: :integer,
        name: :string,
        items: :array
      )
    end

    it "returns error schema when not found" do
      get "/api/v1/restaurants/#{restaurant.id}/menus/999999"

      expect(response).to have_http_status(:not_found)
      expect(response).to have_content_type_json

      json = JSON.parse(response.body)
      expect(json).to have_key("error")
      expect(json["error"]).to be_a(Hash)
      expect(json["error"]).to have_key("message")
    end

    it "returns error when menu belongs to different restaurant" do
      other_restaurant = create(:restaurant)
      other_menu = create(:menu, restaurant: other_restaurant)

      get "/api/v1/restaurants/#{restaurant.id}/menus/#{other_menu.id}"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/restaurants/:restaurant_id/menus" do
    it "returns created menu matching the schema" do
      post "/api/v1/restaurants/#{restaurant.id}/menus", params: { name: "New Menu" }

      expect(response).to have_http_status(:created)
      expect(response).to have_content_type_json

      json = JSON.parse(response.body)
      expect(json).to match_json_schema(
        id: :integer,
        name: :string,
        items: :array
      )
    end

    it "returns validation error schema when invalid" do
      post "/api/v1/restaurants/#{restaurant.id}/menus", params: { name: "" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to have_content_type_json

      json = JSON.parse(response.body)
      expect(json).to have_key("error")
      expect(json["error"]).to be_a(Hash)
      expect(json["error"]).to have_key("message")
      expect(json["error"]).to have_key("details")
      expect(json["error"]["details"]).to be_an(Array)
    end
  end

  describe "PUT /api/v1/restaurants/:restaurant_id/menus/:id" do
    it "returns updated menu matching the schema" do
      put "/api/v1/restaurants/#{restaurant.id}/menus/#{menu.id}",
          params: { name: "Updated Menu" }

      expect(response).to have_http_status(:ok)
      expect(response).to have_content_type_json

      json = JSON.parse(response.body)
      expect(json).to match_json_schema(
        id: :integer,
        name: :string,
        items: :array
      )
    end
  end

  describe "DELETE /api/v1/restaurants/:restaurant_id/menus/:id" do
    it "returns no content on successful deletion" do
      delete "/api/v1/restaurants/#{restaurant.id}/menus/#{menu.id}"

      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
    end
  end

  describe "Menu items in response" do
    it "includes menu items with correct schema" do
      menu_item = create(:menu_item)
      create(:menu_item_placement, menu: menu, menu_item: menu_item, price: 19.99)

      get "/api/v1/restaurants/#{restaurant.id}/menus/#{menu.id}"

      json = JSON.parse(response.body)
      expect(json["items"]).to be_an(Array)
      expect(json["items"].first).to match_json_schema(
        id: :integer,
        name: :string,
        price: :string
      )
    end
  end
end

