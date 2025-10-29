# frozen_string_literal: true

require "rails_helper"

# Contract tests ensure API responses match the defined schemas
# This follows the consumer-driven contract testing pattern
RSpec.describe "Restaurant API Contract", type: :request do
  let(:restaurant) { create(:restaurant) }

  describe "GET /api/v1/restaurants" do
    it "returns response matching the schema" do
      create_list(:restaurant, 3)

      get "/api/v1/restaurants"

      expect(response).to have_http_status(:ok)
      expect(response).to have_content_type_json

      json = JSON.parse(response.body)
      expect(json).to be_an(Array)

      json.each do |restaurant_data|
        expect(restaurant_data).to match_json_schema(
          id: :integer,
          name: :string,
          menus: :array
        )
      end
    end
  end

  describe "GET /api/v1/restaurants/:id" do
    it "returns response matching the schema" do
      get "/api/v1/restaurants/#{restaurant.id}"

      expect(response).to have_http_status(:ok)
      expect(response).to have_content_type_json

      json = JSON.parse(response.body)
      expect(json).to match_json_schema(
        id: :integer,
        name: :string,
        menus: :array
      )
    end

    it "returns error schema when not found" do
      get "/api/v1/restaurants/999999"

      expect(response).to have_http_status(:not_found)
      expect(response).to have_content_type_json

      json = JSON.parse(response.body)
      expect(json).to have_key("error")
      expect(json["error"]).to be_a(Hash)
      expect(json["error"]).to have_key("message")
    end
  end

  describe "POST /api/v1/restaurants" do
    it "returns created restaurant matching the schema" do
      post "/api/v1/restaurants", params: { name: "New Restaurant" }

      expect(response).to have_http_status(:created)
      expect(response).to have_content_type_json

      json = JSON.parse(response.body)
      expect(json).to match_json_schema(
        id: :integer,
        name: :string,
        menus: :array
      )
    end

    it "returns validation error schema when invalid" do
      post "/api/v1/restaurants", params: { name: "" }

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

  describe "PUT /api/v1/restaurants/:id" do
    it "returns updated restaurant matching the schema" do
      put "/api/v1/restaurants/#{restaurant.id}", params: { name: "Updated Name" }

      expect(response).to have_http_status(:ok)
      expect(response).to have_content_type_json

      json = JSON.parse(response.body)
      expect(json).to match_json_schema(
        id: :integer,
        name: :string,
        menus: :array
      )
    end
  end

  describe "DELETE /api/v1/restaurants/:id" do
    it "returns no content on successful deletion" do
      delete "/api/v1/restaurants/#{restaurant.id}"

      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
    end
  end
end

