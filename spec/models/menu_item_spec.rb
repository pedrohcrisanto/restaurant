# frozen_string_literal: true

require "rails_helper"

RSpec.describe MenuItem do
  subject { build(:menu_item) }

  it { is_expected.to have_many(:menu_item_placements).dependent(:destroy) }
  it { is_expected.to have_many(:menus).through(:menu_item_placements) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }

  describe "callbacks" do
    describe "normalizes :name" do
      it "strips leading and trailing whitespace" do
        item = create(:menu_item, name: "  Burger  ")
        expect(item.name).to eq("Burger")
      end

      it "squeezes multiple spaces into one" do
        item = create(:menu_item, name: "Delicious    Burger")
        expect(item.name).to eq("Delicious Burger")
      end

      it "handles both leading/trailing and multiple spaces" do
        item = create(:menu_item, name: "  Delicious    Burger  ")
        expect(item.name).to eq("Delicious Burger")
      end
    end
  end

  describe "scopes" do
    describe ".ordered" do
      it "orders menu items by id" do
        item3 = create(:menu_item)
        item1 = create(:menu_item)
        item2 = create(:menu_item)

        ordered = described_class.ordered
        expect(ordered.first.id).to be < ordered.last.id
      end
    end

    describe ".by_name_ci" do
      let!(:item) { create(:menu_item, name: "Delicious Burger") }

      it "finds item by exact name" do
        result = described_class.by_name_ci("Delicious Burger")
        expect(result).to include(item)
      end

      it "finds item by lowercase name" do
        result = described_class.by_name_ci("delicious burger")
        expect(result).to include(item)
      end

      it "finds item by uppercase name" do
        result = described_class.by_name_ci("DELICIOUS BURGER")
        expect(result).to include(item)
      end

      it "does not find item with different name" do
        result = described_class.by_name_ci("Pizza")
        expect(result).not_to include(item)
      end
    end

    describe ".for_restaurant" do
      let(:restaurant1) { create(:restaurant) }
      let(:restaurant2) { create(:restaurant) }
      let(:menu1) { create(:menu, restaurant: restaurant1) }
      let(:menu2) { create(:menu, restaurant: restaurant2) }
      let(:item1) { create(:menu_item, name: "Item 1") }
      let(:item2) { create(:menu_item, name: "Item 2") }
      let(:item3) { create(:menu_item, name: "Item 3") }

      before do
        create(:menu_item_placement, menu: menu1, menu_item: item1)
        create(:menu_item_placement, menu: menu1, menu_item: item2)
        create(:menu_item_placement, menu: menu2, menu_item: item3)
      end

      it "returns items for specific restaurant" do
        result = described_class.for_restaurant(restaurant1)
        expect(result).to include(item1, item2)
        expect(result).not_to include(item3)
      end

      it "returns distinct items when item appears in multiple menus of same restaurant" do
        menu1_2 = create(:menu, restaurant: restaurant1)
        create(:menu_item_placement, menu: menu1_2, menu_item: item1)

        result = described_class.for_restaurant(restaurant1)
        expect(result.where(id: item1.id).count).to eq(1)
      end

      it "returns empty relation when restaurant has no items" do
        new_restaurant = create(:restaurant)
        result = described_class.for_restaurant(new_restaurant)
        expect(result).to be_empty
      end
    end
  end
end
