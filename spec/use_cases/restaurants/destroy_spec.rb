# frozen_string_literal: true

require "rails_helper"

RSpec.describe Restaurants::Destroy do
  let(:repo) { Repositories::Persistence::RestaurantsRepository.new }
  let(:restaurant) { create(:restaurant) }
  let(:call_params) { { repo: repo, restaurant: restaurant } }

  describe "#call!" do
    # Shared examples for common scenarios
    it_behaves_like "a successful destroy use case", :restaurant, Restaurant
    it_behaves_like "a use case with repository validation"
    it_behaves_like "a use case with resource validation", :restaurant
    it_behaves_like "a use case with error handling", "restaurants.destroy",
                    error_method: :destroy,
                    context: { restaurant_id: restaurant.id }

    context "when successful" do
      it "destroys associated menus" do
        restaurant_with_menus = create(:restaurant)
        create_list(:menu, 2, restaurant: restaurant_with_menus)

        expect do
          described_class.call(repo: repo, restaurant: restaurant_with_menus)
        end.to change(Menu, :count).by(-2)
      end
    end
  end
end
