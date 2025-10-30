# frozen_string_literal: true

require "rails_helper"

RSpec.describe Restaurants::Find do
  let(:repo) { ::Repositories::Persistence::RestaurantsRepository.new }
  let(:restaurant) { create(:restaurant) }
  let(:call_params) { { repo: repo, id: restaurant.id } }

  describe "#call!" do
    # Shared examples for common scenarios
    it_behaves_like "a successful find use case", :restaurant
    it_behaves_like "a use case with repository validation"
    it_behaves_like "a use case with id validation"
    it_behaves_like "a use case with not found error", :restaurant
    it_behaves_like "a use case with error handling", "restaurants.find",
                    error_method: :find,
                    context: { id: -> { call_params[:id] } }

    context "when successful" do
      it "includes eager loaded associations" do
        restaurant_with_menu = create(:restaurant)
        create(:menu, restaurant: restaurant_with_menu)

        result = described_class.call(repo: repo, id: restaurant_with_menu.id)

        expect(result).to be_success
        expect(result[:restaurant].association(:menus)).to be_loaded
      end
    end
  end
end
