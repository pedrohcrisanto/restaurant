# frozen_string_literal: true

require "rails_helper"

RSpec.describe MenuItemPlacement do
  subject { build(:menu_item_placement) }

  it { is_expected.to belong_to(:menu) }
  it { is_expected.to belong_to(:menu_item) }

  it { is_expected.to validate_uniqueness_of(:menu_id).scoped_to(:menu_item_id) }
  it { is_expected.to validate_numericality_of(:price).is_greater_than_or_equal_to(0) }

  describe "validations" do
    describe "price" do
      it "allows zero price" do
        placement = build(:menu_item_placement, price: 0)
        expect(placement).to be_valid
      end

      it "allows positive prices" do
        placement = build(:menu_item_placement, price: 10.50)
        expect(placement).to be_valid
      end

      it "does not allow negative prices" do
        placement = build(:menu_item_placement, price: -1)
        expect(placement).not_to be_valid
        expect(placement.errors[:price]).to be_present
      end

      it "allows decimal prices" do
        placement = build(:menu_item_placement, price: 9.99)
        expect(placement).to be_valid
      end
    end

    describe "uniqueness" do
      let(:menu) { create(:menu) }
      let(:menu_item) { create(:menu_item) }

      it "does not allow duplicate menu_item in same menu" do
        create(:menu_item_placement, menu: menu, menu_item: menu_item)
        duplicate = build(:menu_item_placement, menu: menu, menu_item: menu_item)

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:menu_id]).to be_present
      end

      it "allows same menu_item in different menus" do
        menu2 = create(:menu)
        create(:menu_item_placement, menu: menu, menu_item: menu_item)
        placement2 = build(:menu_item_placement, menu: menu2, menu_item: menu_item)

        expect(placement2).to be_valid
      end

      it "allows different menu_items in same menu" do
        menu_item2 = create(:menu_item)
        create(:menu_item_placement, menu: menu, menu_item: menu_item)
        placement2 = build(:menu_item_placement, menu: menu, menu_item: menu_item2)

        expect(placement2).to be_valid
      end
    end
  end
end
