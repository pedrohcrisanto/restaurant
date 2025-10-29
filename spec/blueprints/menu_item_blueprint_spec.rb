# frozen_string_literal: true

require "rails_helper"

RSpec.describe MenuItemBlueprint do
  describe ".render" do
    let(:menu_item) { create(:menu_item, name: "Delicious Burger") }

    context "with default view" do
      subject(:rendered) { described_class.render_as_hash(menu_item) }

      it "includes id field" do
        expect(rendered[:id]).to eq(menu_item.id)
      end

      it "includes name field" do
        expect(rendered[:name]).to eq("Delicious Burger")
      end

      it "returns a hash" do
        expect(rendered).to be_a(Hash)
      end

      it "only includes id and name fields" do
        expect(rendered.keys).to contain_exactly(:id, :name)
      end
    end

    context "with multiple menu items" do
      let(:menu_items) { create_list(:menu_item, 3) }

      subject(:rendered) { described_class.render_as_json(menu_items) }

      it "renders array of menu items" do
        parsed = JSON.parse(rendered)
        expect(parsed).to be_an(Array)
        expect(parsed.size).to eq(3)
      end

      it "includes all required fields for each menu item" do
        parsed = JSON.parse(rendered)
        parsed.each do |item_hash|
          expect(item_hash).to have_key("id")
          expect(item_hash).to have_key("name")
        end
      end
    end

    context "when rendering as JSON string" do
      subject(:rendered) { described_class.render(menu_item) }

      it "returns valid JSON string" do
        expect { JSON.parse(rendered) }.not_to raise_error
      end

      it "includes correct data in JSON" do
        parsed = JSON.parse(rendered)
        expect(parsed["id"]).to eq(menu_item.id)
        expect(parsed["name"]).to eq("Delicious Burger")
      end
    end
  end
end

