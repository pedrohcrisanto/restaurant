# frozen_string_literal: true

require "rails_helper"

RSpec.describe ::Persistence::RestaurantsRepository do
  subject(:repo) { described_class.new }

  describe "#relation_for_index" do
    it "returns ordered relation including nested associations" do
      r1 = create(:restaurant)
      create(:restaurant)
      create(:menu, restaurant: r1)
      rel = repo.relation_for_index
      expect(rel).to be_a(ActiveRecord::Relation)
      expect(rel.order_values).not_to be_empty
      expect(rel.first).to be_a(Restaurant)
      # Verify eager loading
      expect(rel.first.association(:menus)).to be_loaded
    end
  end

  describe "#find" do
    it "returns record with eager-loaded associations" do
      restaurant = create(:restaurant)
      menu = create(:menu, restaurant: restaurant)
      found = repo.find(restaurant.id)
      expect(found).to be_present
      expect(found.menus.map(&:id)).to include(menu.id)
    end
  end

  describe "#build/#save/#update/#destroy" do
    it "creates, updates and destroys" do
      record = repo.build(name: "Repo R")
      expect(repo.save(record)).to be_truthy
      expect(record).to be_persisted

      expect(repo.update(record, name: "Repo R2")).to be_truthy
      expect(record.reload.name).to eq("Repo R2")

      expect { repo.destroy(record) }.to change(Restaurant, :count).by(-1)
    end
  end

  describe "edge cases" do
    describe "#find" do
      it "raises ActiveRecord::RecordNotFound when record does not exist" do
        expect { repo.find(999_999) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "handles nil id gracefully" do
        expect { repo.find(nil) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "#save" do
      it "returns false when validation fails" do
        record = repo.build(name: "")
        expect(repo.save(record)).to be false
        expect(record).not_to be_persisted
      end

      it "returns false for duplicate names" do
        create(:restaurant, name: "Existing")
        record = repo.build(name: "Existing")
        expect(repo.save(record)).to be false
      end

      it "handles very long names" do
        long_name = "A" * 1000
        record = repo.build(name: long_name)
        expect(repo.save(record)).to be_truthy
      end
    end

    describe "#update" do
      it "returns false when validation fails" do
        restaurant = create(:restaurant)
        expect(repo.update(restaurant, name: "")).to be false
      end

      it "returns false when updating to duplicate name" do
        create(:restaurant, name: "Existing")
        restaurant = create(:restaurant, name: "Original")
        expect(repo.update(restaurant, name: "Existing")).to be false
      end

      it "handles concurrent updates" do
        restaurant = create(:restaurant, name: "Original")
        restaurant_copy = Restaurant.find(restaurant.id)

        repo.update(restaurant, name: "Updated 1")
        expect(repo.update(restaurant_copy, name: "Updated 2")).to be_truthy
      end
    end

    describe "#destroy" do
      it "cascades to associated menus" do
        restaurant = create(:restaurant)
        create_list(:menu, 3, restaurant: restaurant)

        expect { repo.destroy(restaurant) }.to change(Menu, :count).by(-3)
      end

      it "handles destroying already destroyed record" do
        restaurant = create(:restaurant)
        repo.destroy(restaurant)

        expect { repo.destroy(restaurant) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "bulk operations" do
    describe "bulk insert simulation" do
      it "creates multiple restaurants efficiently" do
        restaurants_data = [
          { name: "Restaurant 1" },
          { name: "Restaurant 2" },
          { name: "Restaurant 3" }
        ]

        expect do
          restaurants_data.each do |data|
            record = repo.build(data)
            repo.save(record)
          end
        end.to change(Restaurant, :count).by(3)
      end
    end

    describe "batch updates" do
      it "updates multiple restaurants" do
        restaurants = create_list(:restaurant, 3)

        restaurants.each_with_index do |restaurant, index|
          repo.update(restaurant, name: "Updated #{index}")
        end

        restaurants.each_with_index do |restaurant, index|
          expect(restaurant.reload.name).to eq("Updated #{index}")
        end
      end
    end

    describe "batch deletes" do
      it "destroys multiple restaurants" do
        restaurants = create_list(:restaurant, 5)

        expect do
          restaurants.each { |r| repo.destroy(r) }
        end.to change(Restaurant, :count).by(-5)
      end
    end
  end

  describe "query performance" do
    describe "#relation_for_index" do
      it "eager loads associations to avoid N+1 queries" do
        restaurant = create(:restaurant)
        create_list(:menu, 3, restaurant: restaurant)

        # First query to load the relation
        relation = repo.relation_for_index

        # This should not trigger additional queries
        expect do
          relation.each do |r|
            r.menus.to_a
          end
        end.not_to exceed_query_limit(1)
      end
    end

    describe "#find" do
      it "eager loads nested associations" do
        restaurant = create(:restaurant)
        menu = create(:menu, restaurant: restaurant)
        item = create(:menu_item)
        create(:menu_item_placement, menu: menu, menu_item: item)

        found = repo.find(restaurant.id)

        # Accessing nested associations should not trigger queries
        expect do
          found.menus.first.menu_item_placements.first.menu_item
        end.not_to exceed_query_limit(0)
      end
    end
  end
end
