# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'API V1 MenuItems', type: :request do
  let!(:restaurant) { create(:restaurant) }

  path '/api/v1/restaurants/{restaurant_id}/menu_items' do
    parameter name: :restaurant_id, in: :path, type: :string

    get 'List menu_items for restaurant' do
      tags 'MenuItems'
      produces 'application/json'

      response '200', 'ok' do
        let(:restaurant_id) { restaurant.id }
        before do
          menu = create(:menu, restaurant: restaurant)
          2.times do
            item = create(:menu_item)
            create(:menu_item_placement, menu:, menu_item: item)
          end
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

    post 'Create menu_item' do
      tags 'MenuItems'
      consumes 'application/json'
      parameter name: :menu_item, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        },
        required: %w[name]
      }

      response '201', 'created' do
        let(:restaurant_id) { restaurant.id }
        let(:menu_item) { { name: 'Burger' } }
        run_test!
      end

      response '422', 'invalid' do
        let(:restaurant_id) { restaurant.id }
        let(:menu_item) { { name: '' } }
        run_test!
      end
    end
  end

  path '/api/v1/restaurants/{restaurant_id}/menu_items/{id}' do
    parameter name: :restaurant_id, in: :path, type: :string
    parameter name: :id, in: :path, type: :string

    get 'Show menu_item' do
      tags 'MenuItems'
      response '200', 'ok' do
        let(:restaurant_id) { restaurant.id }
        let(:id) { create(:menu_item_placement, menu: create(:menu, restaurant: restaurant)).menu_item.id }
        run_test!
      end
    end

    patch 'Update menu_item' do
      tags 'MenuItems'
      consumes 'application/json'
      parameter name: :menu_item, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        }
      }

      response '200', 'updated' do
        let(:restaurant_id) { restaurant.id }
        let(:id) { create(:menu_item_placement, menu: create(:menu, restaurant: restaurant)).menu_item.id }
        let(:menu_item) { { name: 'New Name' } }
        run_test!
      end
    end

    delete 'Delete menu_item' do
      tags 'MenuItems'
      response '204', 'deleted' do
        let(:restaurant_id) { restaurant.id }
        let(:id) { create(:menu_item_placement, menu: create(:menu, restaurant: restaurant)).menu_item.id }
        run_test!
      end
    end
  end
end

