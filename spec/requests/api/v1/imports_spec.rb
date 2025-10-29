# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'API V1 Imports', type: :request do
  path '/api/v1/imports/restaurants_json' do
    post 'Import restaurants/menus/items from JSON file' do
      tags 'Imports'
      consumes 'multipart/form-data'
      parameter name: :file, in: :formData, type: :file, required: true

      response '200', 'imported' do
        let(:file) { Rack::Test::UploadedFile.new(Rails.root.join('contexts', 'data.json'), 'application/json') }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['success']).to eq(true)
          expect(json['logs']).to be_an(Array)
          expect(json['logs']).not_to be_empty
        end
      end

      response '422', 'invalid' do
        let(:file) { Rack::Test::UploadedFile.new(StringIO.new('invalid'), 'application/json', original_filename: 'bad.json') }
        run_test!
      end
    end
  end
end

