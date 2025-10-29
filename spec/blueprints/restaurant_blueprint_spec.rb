# frozen_string_literal: true

require "rails_helper"

RSpec.describe RestaurantBlueprint do
  describe ".render" do
    let(:restaurant) { create(:restaurant, name: "Test Restaurant") }

    context "with default view" do
      subject(:rendered) { described_class.render_as_hash(restaurant) }

      it "includes id field" do
        expect(rendered[:id]).to eq(restaurant.id)
      end

      it "includes name field" do
        expect(rendered[:name]).to eq("Test Restaurant")
      end

      it "includes menus association" do
        expect(rendered).to have_key(:menus)
      end

      it "returns a hash" do
        expect(rendered).to be_a(Hash)
      end
    end

    context "with menus association" do
      let!(:menu1) { create(:menu, restaurant: restaurant, name: "Lunch") }
      let!(:menu2) { create(:menu, restaurant: restaurant, name: "Dinner") }

      subject(:rendered) { described_class.render_as_hash(restaurant) }

      it "includes all menus" do
        expect(rendered[:menus]).to be_an(Array)
        expect(rendered[:menus].size).to eq(2)
      end

      it "renders menus with MenuBlueprint" do
        menu_names = rendered[:menus].map { |m| m[:name] }
        expect(menu_names).to contain_exactly("Lunch", "Dinner")
      end
    end

    context "when restaurant has no menus" do
      subject(:rendered) { described_class.render_as_hash(restaurant) }

      it "returns empty menus array" do
        expect(rendered[:menus]).to eq([])
      end
    end

    context "with multiple restaurants" do
      let(:restaurants) { create_list(:restaurant, 3) }

      subject(:rendered) { described_class.render_as_json(restaurants) }

      it "renders array of restaurants" do
        parsed = JSON.parse(rendered)
        expect(parsed).to be_an(Array)
        expect(parsed.size).to eq(3)
      end

      it "includes all required fields for each restaurant" do
        parsed = JSON.parse(rendered)
        parsed.each do |restaurant_hash|
          expect(restaurant_hash).to have_key("id")
          expect(restaurant_hash).to have_key("name")
          expect(restaurant_hash).to have_key("menus")
        end
      end
    end
  end
end

