# frozen_string_literal: true

require "rails_helper"

RSpec.describe Menus::ListForRestaurant do
  let(:repo) { Repositories::Persistence::MenusRepository.new }
  let(:restaurant) { create(:restaurant) }
  let(:call_params) { { restaurant: restaurant, repo: repo } }

  describe "#call!" do
    # Shared examples for common scenarios
    it_behaves_like "a use case with resource validation", :restaurant
    it_behaves_like "a use case with error handling", "menus.list_for_restaurant",
                    error_method: :for_restaurant,
                    context: { restaurant_id: -> { restaurant.id } }

    context "when successful" do
      it "returns menus for a restaurant" do
        create_list(:menu, 3, restaurant: restaurant)
        result = described_class.call(**call_params)

        expect(result).to be_success
        expect(result[:menus].count).to eq(3)
      end

      it "returns empty array when restaurant has no menus" do
        result = described_class.call(**call_params)

        expect(result).to be_success
        expect(result[:menus].count).to eq(0)
      end

      it "includes eager loaded associations" do
        menu = create(:menu, restaurant: restaurant)
        item = create(:menu_item)
        create(:menu_item_placement, menu: menu, menu_item: item)

        result = described_class.call(**call_params)

        expect(result).to be_success
        expect(result[:menus].first.association(:menu_item_placements)).to be_loaded
      end

      it "does not return menus from other restaurants" do
        other_restaurant = create(:restaurant)
        create(:menu, restaurant: other_restaurant)
        create(:menu, restaurant: restaurant)

        result = described_class.call(**call_params)

        expect(result).to be_success
        expect(result[:menus].count).to eq(1)
      end
    end
  end
end
