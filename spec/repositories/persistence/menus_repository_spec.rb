# frozen_string_literal: true

require "rails_helper"

RSpec.describe Repositories::Persistence::MenusRepository do
  subject(:repo) { described_class.new }

  let!(:restaurant) { create(:restaurant) }

  describe "#for_restaurant" do
    it "returns ordered relation including placements and items" do
      menu = create(:menu, restaurant: restaurant)
      item = create(:menu_item)
      create(:menu_item_placement, menu: menu, menu_item: item)

      rel = repo.for_restaurant(restaurant)
      expect(rel).to be_a(ActiveRecord::Relation)
      expect(rel.order_values).not_to be_empty
      expect(rel.first).to be_a(Menu)
      # Verify eager loading
      expect(rel.first.association(:menu_item_placements)).to be_loaded
    end
  end

  describe "#find_by_restaurant" do
    it "returns only menus belonging to the restaurant" do
      menu = create(:menu, restaurant: restaurant)
      other_menu = create(:menu) # different restaurant
      found = repo.find_by_restaurant(restaurant, menu.id)
      expect(found).to be_present
      expect(found.id).to eq(menu.id)
      expect(found.id).not_to eq(other_menu.id)
    end
  end

  describe "build/save/update/destroy" do
    it "creates, updates and destroys a menu" do
      record = repo.build_for(restaurant, name: "Repo Menu")
      expect(repo.save(record)).to be_truthy
      expect(record).to be_persisted

      expect(repo.update(record, name: "Repo Menu 2")).to be_truthy
      expect(record.reload.name).to eq("Repo Menu 2")

      expect { repo.destroy(record) }.to change(Menu, :count).by(-1)
    end
  end

  describe "edge cases" do
    describe "#find_by_restaurant" do
      it "raises ActiveRecord::RecordNotFound when menu does not exist" do
        expect { repo.find_by_restaurant(restaurant, 999_999) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "raises ActiveRecord::RecordNotFound when menu belongs to different restaurant" do
        other_restaurant = create(:restaurant)
        other_menu = create(:menu, restaurant: other_restaurant)

        expect do
          repo.find_by_restaurant(restaurant, other_menu.id)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "handles nil id gracefully" do
        expect { repo.find_by_restaurant(restaurant, nil) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "#for_restaurant" do
      it "returns empty relation when restaurant has no menus" do
        new_restaurant = create(:restaurant)
        rel = repo.for_restaurant(new_restaurant)
        expect(rel).to be_empty
      end

      it "does not return menus from other restaurants" do
        create(:menu, restaurant: restaurant, name: "My Menu")
        other_restaurant = create(:restaurant)
        create(:menu, restaurant: other_restaurant, name: "Other Menu")

        rel = repo.for_restaurant(restaurant)
        expect(rel.count).to eq(1)
        expect(rel.first.name).to eq("My Menu")
      end
    end

    describe "#save" do
      it "returns false when validation fails" do
        record = repo.build_for(restaurant, name: "")
        expect(repo.save(record)).to be false
      end

      it "returns false for duplicate name in same restaurant" do
        create(:menu, restaurant: restaurant, name: "Existing")
        record = repo.build_for(restaurant, name: "Existing")
        expect(repo.save(record)).to be false
      end

      it "allows duplicate name in different restaurants" do
        other_restaurant = create(:restaurant)
        create(:menu, restaurant: other_restaurant, name: "Menu")
        record = repo.build_for(restaurant, name: "Menu")
        expect(repo.save(record)).to be_truthy
      end
    end

    describe "#destroy" do
      it "cascades to associated menu_item_placements" do
        menu = create(:menu, restaurant: restaurant)
        create_list(:menu_item_placement, 3, menu: menu)

        expect { repo.destroy(menu) }.to change(MenuItemPlacement, :count).by(-3)
      end
    end
  end

  describe "bulk operations" do
    describe "bulk create menus for restaurant" do
      it "creates multiple menus for same restaurant" do
        menus_data = [
          { name: "Breakfast" },
          { name: "Lunch" },
          { name: "Dinner" }
        ]

        expect do
          menus_data.each do |data|
            record = repo.build_for(restaurant, data)
            repo.save(record)
          end
        end.to change(Menu, :count).by(3)

        expect(restaurant.menus.count).to eq(3)
      end
    end

    describe "batch updates" do
      it "updates multiple menus" do
        menus = create_list(:menu, 3, restaurant: restaurant)

        menus.each_with_index do |menu, index|
          repo.update(menu, name: "Updated Menu #{index}")
        end

        menus.each_with_index do |menu, index|
          expect(menu.reload.name).to eq("Updated Menu #{index}")
        end
      end
    end
  end

  describe "query performance" do
    describe "#for_restaurant" do
      it "eager loads associations to avoid N+1 queries" do
        menu = create(:menu, restaurant: restaurant)
        create_list(:menu_item_placement, 3, menu: menu)

        relation = repo.for_restaurant(restaurant)

        expect do
          relation.each do |m|
            m.menu_item_placements.to_a
          end
        end.not_to exceed_query_limit(1)
      end
    end

    describe "#find_by_restaurant" do
      it "eager loads nested associations" do
        menu = create(:menu, restaurant: restaurant)
        item = create(:menu_item)
        create(:menu_item_placement, menu: menu, menu_item: item)

        found = repo.find_by_restaurant(restaurant, menu.id)

        expect do
          found.menu_item_placements.first.menu_item
        end.not_to exceed_query_limit(0)
      end
    end
  end
end
