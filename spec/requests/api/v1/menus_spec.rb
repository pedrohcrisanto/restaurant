# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'API V1 Menus', type: :request do
  let!(:restaurant) { create(:restaurant) }

  path '/api/v1/restaurants/{restaurant_id}/menus' do
    parameter name: :restaurant_id, in: :path, type: :string

    get 'List menus for restaurant' do
      tags 'Menus'
      produces 'application/json'

      response '200', 'ok' do
        let(:restaurant_id) { restaurant.id }
        before { create_list(:menu, 2, restaurant:) }

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

    post 'Create menu' do
      tags 'Menus'
      consumes 'application/json'
      parameter name: :menu, in: :body, schema: {
        type: :object,
        properties: { name: { type: :string } },
        required: %w[name]
      }

      response '201', 'created' do
        let(:restaurant_id) { restaurant.id }
        let(:menu) { { name: 'Lunch' } }
        run_test!
      end

      response '422', 'invalid' do
        let(:restaurant_id) { restaurant.id }
        let(:menu) { { name: '' } }
        run_test!
      end
    end
  end

  path '/api/v1/restaurants/{restaurant_id}/menus/{id}' do
    parameter name: :restaurant_id, in: :path, type: :string
    parameter name: :id, in: :path, type: :string

    get 'Show menu' do
      tags 'Menus'
      response '200', 'ok' do
        let(:restaurant_id) { restaurant.id }
        let(:id) { create(:menu, restaurant:).id }
        run_test!
      end
    end

    patch 'Update menu' do
      tags 'Menus'
      consumes 'application/json'
      parameter name: :menu, in: :body, schema: {
        type: :object,
        properties: { name: { type: :string } }
      }

      response '200', 'updated' do
        let(:restaurant_id) { restaurant.id }
        let(:id) { create(:menu, restaurant:).id }
        let(:menu) { { name: 'Dinner' } }
        run_test!
      end
    end

    delete 'Delete menu' do
      tags 'Menus'
      response '204', 'deleted' do
        let(:restaurant_id) { restaurant.id }
        let(:id) { create(:menu, restaurant:).id }
        run_test!
      end
    end
  end
end

