# frozen_string_literal: true

require "rails_helper"

RSpec.describe Menu do
  subject { build(:menu) }

  it { is_expected.to belong_to(:restaurant) }
  it { is_expected.to have_many(:menu_item_placements).dependent(:destroy) }
  it { is_expected.to have_many(:menu_items).through(:menu_item_placements) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:restaurant_id).case_insensitive }

  describe "callbacks" do
    describe "normalizes :name" do
      it "strips leading and trailing whitespace" do
        menu = create(:menu, name: "  Lunch Menu  ")
        expect(menu.name).to eq("Lunch Menu")
      end

      it "squeezes multiple spaces into one" do
        menu = create(:menu, name: "Lunch    Menu")
        expect(menu.name).to eq("Lunch Menu")
      end

      it "handles both leading/trailing and multiple spaces" do
        menu = create(:menu, name: "  Lunch    Menu  ")
        expect(menu.name).to eq("Lunch Menu")
      end
    end
  end

  describe "scopes" do
    describe ".ordered" do
      it "orders menus by id" do
        restaurant = create(:restaurant)
        menu3 = create(:menu, restaurant: restaurant)
        menu1 = create(:menu, restaurant: restaurant)
        menu2 = create(:menu, restaurant: restaurant)

        ordered = described_class.ordered
        expect(ordered.first.id).to be < ordered.last.id
      end
    end

    describe ".with_items" do
      let(:menu) { create(:menu) }
      let(:menu_item) { create(:menu_item) }

      before do
        create(:menu_item_placement, menu: menu, menu_item: menu_item)
      end

      it "eager loads menu_item_placements" do
        result = described_class.with_items.find(menu.id)
        expect(result.association(:menu_item_placements)).to be_loaded
      end

      it "eager loads menu_items through menu_item_placements" do
        result = described_class.with_items.find(menu.id)
        expect(result.menu_item_placements.first.association(:menu_item)).to be_loaded
      end
    end

    describe ".by_name_ci" do
      let(:restaurant) { create(:restaurant) }
      let!(:menu) { create(:menu, restaurant: restaurant, name: "Lunch Menu") }

      it "finds menu by exact name" do
        result = described_class.by_name_ci("Lunch Menu")
        expect(result).to include(menu)
      end

      it "finds menu by lowercase name" do
        result = described_class.by_name_ci("lunch menu")
        expect(result).to include(menu)
      end

      it "finds menu by uppercase name" do
        result = described_class.by_name_ci("LUNCH MENU")
        expect(result).to include(menu)
      end

      it "finds menu by mixed case name" do
        result = described_class.by_name_ci("LuNcH MeNu")
        expect(result).to include(menu)
      end

      it "does not find menu with different name" do
        result = described_class.by_name_ci("Dinner Menu")
        expect(result).not_to include(menu)
      end
    end
  end
end
