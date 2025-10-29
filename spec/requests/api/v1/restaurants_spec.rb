# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'API V1 Restaurants', type: :request do
  path '/api/v1/restaurants' do
    get 'List restaurants' do
      tags 'Restaurants'
      produces 'application/json'

      response '200', 'ok' do
        before do
          create(:restaurant, name: 'Poppo\'s Cafe')
          create(:restaurant, name: 'Casa del Poppo')
        end

        # Pagination headers (when Pagy is available)
        header 'Current-Page', schema: { type: :integer }
        header 'Page-Items',   schema: { type: :integer }
        header 'Total-Count',  schema: { type: :integer }
        header 'Total-Pages',  schema: { type: :integer }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json).to be_a(Array)
          expect(json.size).to be >= 2
        end
      end
    end

    post 'Create restaurant' do
      tags 'Restaurants'
      consumes 'application/json'
      parameter name: :restaurant, in: :body, schema: {
        type: :object,
        properties: { name: { type: :string } },
        required: %w[name]
      }

      response '201', 'created' do
        let(:restaurant) { { name: 'New Resto' } }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['name']).to eq('New Resto')
        end
      end

      response '422', 'invalid' do
        let(:restaurant) { { name: '' } }
        run_test!
      end
    end
  end

  path '/api/v1/restaurants/{id}' do
    parameter name: :id, in: :path, type: :string

    get 'Show restaurant' do
      tags 'Restaurants'
      produces 'application/json'

      response '200', 'ok' do
        let(:id) { create(:restaurant).id }
        run_test!
      end

      response '404', 'not found' do
        let(:id) { '0' }
        run_test!
      end
    end

    patch 'Update restaurant' do
      tags 'Restaurants'
      consumes 'application/json'
      parameter name: :restaurant, in: :body, schema: {
        type: :object,
        properties: { name: { type: :string } }
      }

      response '200', 'updated' do
        let(:id) { create(:restaurant).id }
        let(:restaurant) { { name: 'Updated' } }
        run_test!
      end
    end

    delete 'Delete restaurant' do
      tags 'Restaurants'
      response '204', 'deleted' do
        let(:id) { create(:restaurant).id }
        run_test!
      end
    end
  end
end

