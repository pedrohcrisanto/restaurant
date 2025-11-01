# frozen_string_literal: true

require "rails_helper"

RSpec.describe Restaurants::List do
  let(:repo) { ::Persistence::RestaurantsRepository.new }
  let(:call_params) { { repo: repo } }

  describe "#call!" do
    # Shared examples for common scenarios
    it_behaves_like "a use case with repository validation"
    it_behaves_like "a use case with error handling", "restaurants.list",
                    error_method: :relation_for_index,
                    context: {}

    context "when successful" do
      it "returns a relation with restaurants" do
        create_list(:restaurant, 3)
        result = described_class.call(repo: repo)

        expect(result).to be_success
        relation = result[:relation]
        expect(relation).to be_a(ActiveRecord::Relation)
        expect(relation.count).to be >= 3
      end

      it "returns an empty relation when no restaurants exist" do
        Restaurant.destroy_all
        result = described_class.call(repo: repo)

        expect(result).to be_success
        expect(result[:relation].count).to eq(0)
      end

      it "includes eager loaded associations" do
        restaurant = create(:restaurant)
        create(:menu, restaurant: restaurant)

        result = described_class.call(repo: repo)

        expect(result).to be_success
        first_restaurant = result[:relation].first
        expect(first_restaurant.association(:menus)).to be_loaded
      end
    end
  end
end
