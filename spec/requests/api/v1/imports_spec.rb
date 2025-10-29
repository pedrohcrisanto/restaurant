# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Api::V1::Imports", type: :request do
  let(:json) { JSON.parse(response.body) }

  path "/api/v1/imports/restaurants_json" do
    post "Import restaurants via JSON file" do
      tags "Imports"
      consumes "multipart/form-data"
      produces "application/json"
      parameter name: :file, in: :formData, required: true, schema: { type: :string, format: :binary }

      response "200", "import processed" do
        let(:file) { fixture_file_upload(Rails.root.join("spec/fixtures/files/restaurants.json"), "application/json") }

        run_test! do |response|
          expect(response).to have_http_status(:ok)
          expect(json["success"]).to eq(true)
          expect(json["logs"]).to be_an(Array)
        end
      end

      response "422", "invalid JSON" do
        let(:file) { fixture_file_upload(Rails.root.join("spec/fixtures/files/invalid.json"), "application/json") }

        run_test! do |response|
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json["success"]).to eq(false)
          expect(json["logs"]).to be_an(Array)
        end
      end
    end
  end
end
