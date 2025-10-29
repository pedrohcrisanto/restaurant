# frozen_string_literal: true

require "rails_helper"

RSpec.describe MenuItemPlacementBlueprint do
  describe ".render" do
    let(:menu) { create(:menu) }
    let(:menu_item) { create(:menu_item, name: "Gourmet Burger") }
    let(:placement) { create(:menu_item_placement, menu: menu, menu_item: menu_item, price: 15.99) }

    context "with default view" do
      subject(:rendered) { described_class.render_as_hash(placement) }

      it "includes id field from menu_item_id" do
        expect(rendered[:id]).to eq(menu_item.id)
      end

      it "includes name field from menu_item" do
        expect(rendered[:name]).to eq("Gourmet Burger")
      end

      it "includes price field" do
        expect(rendered[:price]).to eq("15.99")
      end

      it "returns a hash" do
        expect(rendered).to be_a(Hash)
      end

      it "only includes id, name and price fields" do
        expect(rendered.keys).to contain_exactly(:id, :name, :price)
      end
    end

    context "with different prices" do
      let(:placement1) { create(:menu_item_placement, menu: menu, menu_item: menu_item, price: 10.00) }
      let(:placement2) { create(:menu_item_placement, menu: create(:menu), menu_item: menu_item, price: 12.50) }

      it "renders correct price for each placement" do
        rendered1 = described_class.render_as_hash(placement1)
        rendered2 = described_class.render_as_hash(placement2)

        expect(rendered1[:price]).to eq("10.0")
        expect(rendered2[:price]).to eq("12.5")
      end
    end

    context "with zero price" do
      let(:free_placement) { create(:menu_item_placement, menu: menu, menu_item: menu_item, price: 0) }

      subject(:rendered) { described_class.render_as_hash(free_placement) }

      it "renders zero price correctly" do
        expect(rendered[:price]).to eq("0.0")
      end
    end

    context "with multiple placements" do
      let(:placements) do
        [
          create(:menu_item_placement, menu: menu, price: 10.00),
          create(:menu_item_placement, menu: menu, price: 15.50),
          create(:menu_item_placement, menu: menu, price: 8.75)
        ]
      end

      subject(:rendered) { described_class.render_as_json(placements) }

      it "renders array of placements" do
        parsed = JSON.parse(rendered)
        expect(parsed).to be_an(Array)
        expect(parsed.size).to eq(3)
      end

      it "includes all required fields for each placement" do
        parsed = JSON.parse(rendered)
        parsed.each do |placement_hash|
          expect(placement_hash).to have_key("id")
          expect(placement_hash).to have_key("name")
          expect(placement_hash).to have_key("price")
        end
      end
    end
  end
end

