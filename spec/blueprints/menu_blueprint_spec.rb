# frozen_string_literal: true

require "rails_helper"

RSpec.describe MenuBlueprint do
  describe ".render" do
    let(:restaurant) { create(:restaurant) }
    let(:menu) { create(:menu, restaurant: restaurant, name: "Lunch Menu") }

    context "with default view" do
      subject(:rendered) { described_class.render_as_hash(menu) }

      it "includes id field" do
        expect(rendered[:id]).to eq(menu.id)
      end

      it "includes name field" do
        expect(rendered[:name]).to eq("Lunch Menu")
      end

      it "includes items association" do
        expect(rendered).to have_key(:items)
      end

      it "returns a hash" do
        expect(rendered).to be_a(Hash)
      end
    end

    context "with menu_item_placements association" do
      before do
        # Ensure no pre-existing items with these literal names interfere with uniqueness validations
        MenuItem.where(name: ["Burger", "Salad"]).delete_all
      end

      let(:menu_item1) { create(:menu_item, name: "Burger") }
      let(:menu_item2) { create(:menu_item, name: "Salad") }
      let!(:placement1) { create(:menu_item_placement, menu: menu, menu_item: menu_item1, price: 10.50) }
      let!(:placement2) { create(:menu_item_placement, menu: menu, menu_item: menu_item2, price: 7.25) }

      subject(:rendered) { described_class.render_as_hash(menu) }

      it "includes all menu item placements as items" do
        expect(rendered[:items]).to be_an(Array)
        expect(rendered[:items].size).to eq(2)
      end

      it "renders items with MenuItemPlacementBlueprint" do
        item_names = rendered[:items].map { |i| i[:name] }
        expect(item_names).to contain_exactly("Burger", "Salad")
      end

      it "includes prices for each item" do
        prices = rendered[:items].map { |i| i[:price] }
        expect(prices).to contain_exactly("10.5", "7.25")
      end
    end

    context "when menu has no items" do
      subject(:rendered) { described_class.render_as_hash(menu) }

      it "returns empty items array" do
        expect(rendered[:items]).to eq([])
      end
    end

    context "with multiple menus" do
      let(:menus) { create_list(:menu, 3, restaurant: restaurant) }

      subject(:rendered) { described_class.render_as_json(menus) }

      it "renders array of menus" do
        parsed = JSON.parse(rendered)
        expect(parsed).to be_an(Array)
        expect(parsed.size).to eq(3)
      end

      it "includes all required fields for each menu" do
        parsed = JSON.parse(rendered)
        parsed.each do |menu_hash|
          expect(menu_hash).to have_key("id")
          expect(menu_hash).to have_key("name")
          expect(menu_hash).to have_key("items")
        end
      end
    end
  end
end

