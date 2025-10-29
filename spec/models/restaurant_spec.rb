# frozen_string_literal: true

require "rails_helper"

RSpec.describe Restaurant do
  subject { build(:restaurant) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }

  it { is_expected.to have_many(:menus).dependent(:destroy) }
  it { is_expected.to have_many(:menu_item_placements).through(:menus) }
  it { is_expected.to have_many(:menu_items).through(:menu_item_placements) }

  describe "callbacks" do
    describe "normalizes :name" do
      it "strips leading and trailing whitespace" do
        restaurant = create(:restaurant, name: "  Test Restaurant  ")
        expect(restaurant.name).to eq("Test Restaurant")
      end

      it "squeezes multiple spaces into one" do
        restaurant = create(:restaurant, name: "Test    Restaurant")
        expect(restaurant.name).to eq("Test Restaurant")
      end

      it "handles both leading/trailing and multiple spaces" do
        restaurant = create(:restaurant, name: "  Test    Restaurant  ")
        expect(restaurant.name).to eq("Test Restaurant")
      end
    end
  end

  describe "scopes" do
    describe ".ordered" do
      it "orders restaurants by id" do
        restaurant3 = create(:restaurant)
        restaurant1 = create(:restaurant)
        restaurant2 = create(:restaurant)

        ordered = described_class.ordered
        expect(ordered.first.id).to be < ordered.last.id
      end
    end

    describe ".with_full_associations" do
      let(:restaurant) { create(:restaurant) }
      let(:menu) { create(:menu, restaurant: restaurant) }
      let(:menu_item) { create(:menu_item) }

      before do
        create(:menu_item_placement, menu: menu, menu_item: menu_item)
      end

      it "eager loads menus" do
        result = described_class.with_full_associations.find(restaurant.id)
        expect(result.association(:menus)).to be_loaded
      end

      it "eager loads menu_item_placements through menus" do
        result = described_class.with_full_associations.find(restaurant.id)
        expect(result.menus.first.association(:menu_item_placements)).to be_loaded
      end

      it "eager loads menu_items through menu_item_placements" do
        result = described_class.with_full_associations.find(restaurant.id)
        expect(result.menus.first.menu_item_placements.first.association(:menu_item)).to be_loaded
      end
    end

    describe ".by_name_ci" do
      let!(:restaurant) { create(:restaurant, name: "Test Restaurant") }

      it "finds restaurant by exact name" do
        result = described_class.by_name_ci("Test Restaurant")
        expect(result).to include(restaurant)
      end

      it "finds restaurant by lowercase name" do
        result = described_class.by_name_ci("test restaurant")
        expect(result).to include(restaurant)
      end

      it "finds restaurant by uppercase name" do
        result = described_class.by_name_ci("TEST RESTAURANT")
        expect(result).to include(restaurant)
      end

      it "finds restaurant by mixed case name" do
        result = described_class.by_name_ci("TeSt ReStAuRaNt")
        expect(result).to include(restaurant)
      end

      it "does not find restaurant with different name" do
        result = described_class.by_name_ci("Other Restaurant")
        expect(result).not_to include(restaurant)
      end
    end
  end
end
