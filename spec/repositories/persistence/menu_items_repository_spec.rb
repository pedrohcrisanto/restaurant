# frozen_string_literal: true

require "rails_helper"

RSpec.describe ::Persistence::MenuItemsRepository do
  subject(:repo) { described_class.new }

  let!(:restaurant_a) { create(:restaurant) }
  let!(:restaurant_b) { create(:restaurant) }

  describe "#for_restaurant" do
    it "returns distinct items for the given restaurant" do
      menu_a1 = create(:menu, restaurant: restaurant_a)
      menu_b1 = create(:menu, restaurant: restaurant_b)
      item_shared = create(:menu_item)
      item_a_only = create(:menu_item)

      create(:menu_item_placement, menu: menu_a1, menu_item: item_shared)
      create(:menu_item_placement, menu: menu_b1, menu_item: item_shared)
      create(:menu_item_placement, menu: menu_a1, menu_item: item_a_only)

      rel = repo.for_restaurant(restaurant_a)
      expect(rel).to be_a(ActiveRecord::Relation)
      ids = rel.pluck(:id)
      expect(ids).to include(item_shared.id, item_a_only.id)
    end
  end

  describe "#find_by_restaurant" do
    it "finds only when the item is available for the restaurant" do
      menu_a1 = create(:menu, restaurant: restaurant_a)
      menu_b1 = create(:menu, restaurant: restaurant_b)
      item_shared = create(:menu_item)
      item_b_only = create(:menu_item)

      create(:menu_item_placement, menu: menu_a1, menu_item: item_shared)
      create(:menu_item_placement, menu: menu_b1, menu_item: item_shared)
      create(:menu_item_placement, menu: menu_b1, menu_item: item_b_only)

      expect(repo.find_by_restaurant(restaurant_a, item_shared.id)).to be_present
      expect(repo.find_by_restaurant(restaurant_a, item_b_only.id)).to be_nil
    end
  end

  describe "build/save/update/destroy" do
    it "creates, updates and destroys a menu item" do
      record = repo.build(name: "Repo Item")
      expect(repo.save(record)).to be_truthy
      expect(record).to be_persisted

      expect(repo.update(record, name: "Repo Item 2")).to be_truthy
      expect(record.reload.name).to eq("Repo Item 2")

      expect { repo.destroy(record) }.to change(MenuItem, :count).by(-1)
    end
  end
end
