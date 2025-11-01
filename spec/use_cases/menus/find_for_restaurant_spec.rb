# frozen_string_literal: true

require "rails_helper"

RSpec.describe Menus::FindForRestaurant do
  let(:repo) { ::Persistence::MenusRepository.new }
  let(:restaurant) { create(:restaurant) }
  let(:menu) { create(:menu, restaurant: restaurant) }
  let(:call_params) { { restaurant: restaurant, id: menu.id, repo: repo } }

  describe "#call!" do
    # Shared examples for common scenarios
    it_behaves_like "a use case with resource validation", :restaurant
    it_behaves_like "a use case with id validation"
    it_behaves_like "a use case with error handling", "menus.find_for_restaurant",
                    error_method: :find_by_restaurant,
                    context: { restaurant_id: -> { restaurant.id }, menu_id: -> { call_params[:id] } }

    context "when successful" do
      it "finds a menu for a restaurant" do
        result = described_class.call(**call_params)

        expect(result).to be_success
        expect(result[:menu].id).to eq(menu.id)
      end

      it "includes eager loaded associations" do
        menu_with_items = create(:menu, restaurant: restaurant)
        item = create(:menu_item)
        create(:menu_item_placement, menu: menu_with_items, menu_item: item)

        result = described_class.call(restaurant: restaurant, id: menu_with_items.id, repo: repo)

        expect(result).to be_success
        expect(result[:menu].association(:menu_item_placements)).to be_loaded
      end
    end

    context "when menu is not found" do
      it "returns failure" do
        result = described_class.call(restaurant: restaurant, id: 999_999, repo: repo)

        expect(result).to be_failure
        expect(result.type).to eq(:not_found)
        expect(result[:error]).to eq(I18n.t("errors.menus.not_found"))
      end
    end

    context "when menu belongs to another restaurant" do
      it "returns failure" do
        other_restaurant = create(:restaurant)
        other_menu = create(:menu, restaurant: other_restaurant)

        result = described_class.call(restaurant: restaurant, id: other_menu.id, repo: repo)

        expect(result).to be_failure
        expect(result.type).to eq(:not_found)
      end
    end
  end
end
