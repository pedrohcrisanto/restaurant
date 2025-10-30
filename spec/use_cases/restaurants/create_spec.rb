# frozen_string_literal: true

require "rails_helper"

RSpec.describe Restaurants::Create do
  let(:repo) { Repositories::Persistence::RestaurantsRepository.new }
  let(:call_params) { { repo: repo, params: { name: "New Resto" } } }

  describe "#call!" do
    # Shared examples for common scenarios
    it_behaves_like "a successful create use case", :restaurant
    it_behaves_like "a use case with repository validation"
    it_behaves_like "a use case with params validation"
    it_behaves_like "a use case with error handling", "restaurants.create",
                    error_method: :save,
                    context: { params: -> { call_params[:params] } }

    context "when validation fails" do
      it "fails with blank name" do
        result = described_class.call(repo: repo, params: { name: "" })

        expect(result).to be_failure
        expect(result.type).to eq(:invalid)
        expect(result[:error]).to be_present
      end

      it "fails with duplicate name" do
        create(:restaurant, name: "Existing")
        result = described_class.call(repo: repo, params: { name: "Existing" })

        expect(result).to be_failure
        expect(result.type).to eq(:invalid)
        expect(result[:error]).to include(/already been taken/i)
      end

      it "fails with nil name" do
        result = described_class.call(repo: repo, params: { name: nil })

        expect(result).to be_failure
        expect(result[:error]).to be_present
      end
    end
  end
end
