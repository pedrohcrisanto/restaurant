# frozen_string_literal: true

require "rails_helper"

RSpec.describe Menus::Create do
  let(:repo) { ::Persistence::MenusRepository.new }
  let(:restaurant) { create(:restaurant) }
  let(:call_params) { { restaurant: restaurant, params: { name: "Lunch Menu" }, repo: repo } }

  describe "#call!" do
    # Shared examples for common scenarios
    it_behaves_like "a use case with params validation"
    it_behaves_like "a use case with resource validation", :restaurant
    it_behaves_like "a use case with error handling", "menus.create",
                    error_method: :save,
                    context: { restaurant_id: -> { restaurant.id }, params: -> { call_params[:params] } }

    context "when successful" do
      it "creates a menu with valid params" do
        result = described_class.call(**call_params)

        expect(result).to be_success
        expect(result[:menu]).to be_persisted
        expect(result[:menu].name).to eq("Lunch Menu")
        expect(result[:menu].restaurant_id).to eq(restaurant.id)
      end

      it "normalizes the menu name" do
        result = described_class.call(restaurant: restaurant, params: { name: "  Multiple   Spaces  " }, repo: repo)

        expect(result).to be_success
        expect(result[:menu].name).to eq("Multiple Spaces")
      end
    end

    context "when validation fails" do
      it "fails with blank name" do
        result = described_class.call(restaurant: restaurant, params: { name: "" }, repo: repo)

        expect(result).to be_failure
        expect(result.type).to eq(:invalid)
        expect(result[:error]).to be_present
      end

      it "fails with duplicate name for same restaurant" do
        create(:menu, restaurant: restaurant, name: "Existing")
        result = described_class.call(restaurant: restaurant, params: { name: "Existing" }, repo: repo)

        expect(result).to be_failure
        expect(result.type).to eq(:invalid)
        expect(result[:error]).to include(/already been taken/i)
      end

      it "allows duplicate name for different restaurants" do
        other_restaurant = create(:restaurant)
        create(:menu, restaurant: other_restaurant, name: "Menu")

        result = described_class.call(restaurant: restaurant, params: { name: "Menu" }, repo: repo)

        expect(result).to be_success
      end
    end
  end
end
