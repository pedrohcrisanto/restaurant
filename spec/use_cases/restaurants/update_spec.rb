# frozen_string_literal: true

require "rails_helper"

RSpec.describe Restaurants::Update do
  let(:repo) { Repositories::Persistence::RestaurantsRepository.new }
  let(:restaurant) { create(:restaurant, name: "Original") }
  let(:call_params) { { repo: repo, restaurant: restaurant, params: { name: "Updated" } } }

  describe "#call!" do
    # Shared examples for common scenarios
    it_behaves_like "a successful update use case", :restaurant
    it_behaves_like "a use case with repository validation"
    it_behaves_like "a use case with params validation"
    it_behaves_like "a use case with resource validation", :restaurant
    it_behaves_like "a use case with error handling", "restaurants.update",
                    error_method: :update,
                    context: { restaurant_id: -> { restaurant.id }, params: { name: "Test" } }

    context "when validation fails" do
      it "fails with blank name" do
        result = described_class.call(repo: repo, restaurant: restaurant, params: { name: "" })

        expect(result).to be_failure
        expect(result.type).to eq(:invalid)
        expect(result[:error]).to be_present
      end

      it "fails with duplicate name" do
        create(:restaurant, name: "Existing")
        result = described_class.call(repo: repo, restaurant: restaurant, params: { name: "Existing" })

        expect(result).to be_failure
        expect(result.type).to eq(:invalid)
        expect(result[:error]).to include(/already been taken/i)
      end
    end
  end
end
