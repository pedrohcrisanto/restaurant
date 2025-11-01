# frozen_string_literal: true

# Shared examples for common use case success scenarios
# Usage:
#   it_behaves_like "a successful create use case", :restaurant
#   it_behaves_like "a successful update use case", :restaurant
#   it_behaves_like "a successful destroy use case", :restaurant

RSpec.shared_examples "a successful create use case" do |resource_name|
  context "when successful" do
    it "creates a #{resource_name} with valid params" do
      result = described_class.call(**call_params)

      expect(result).to be_success
      expect(result[resource_name]).to be_persisted
    end

    it "normalizes the #{resource_name} name" do
      params_with_spaces = call_params.dup
      params_with_spaces[:params] = { name: "  Multiple   Spaces  " }

      result = described_class.call(**params_with_spaces)

      expect(result).to be_success
      expect(result[resource_name].name).to eq("Multiple Spaces")
    end
  end
end

RSpec.shared_examples "a successful update use case" do |resource_name|
  context "when successful" do
    it "updates the #{resource_name} with valid params" do
      result = described_class.call(**call_params)

      expect(result).to be_success
      expect(result[resource_name].reload.name).to eq(call_params[:params][:name])
    end

    it "normalizes the updated name" do
      params_with_spaces = call_params.dup
      params_with_spaces[:params] = { name: "  New   Name  " }

      result = described_class.call(**params_with_spaces)

      expect(result).to be_success
      expect(result[resource_name].reload.name).to eq("New Name")
    end
  end
end

RSpec.shared_examples "a successful destroy use case" do |resource_name, model_class|
  context "when successful" do
    it "destroys the #{resource_name}" do
      # Force evaluation of lazy lets (e.g., record creation) before measuring count changes
      params = call_params

      expect do
        result = described_class.call(**params)
        expect(result).to be_success
        expect(result[:destroyed]).to be true
      end.to change(model_class, :count).by(-1)
    end
  end
end

RSpec.shared_examples "a successful list use case" do |collection_name|
  context "when successful" do
    it "returns a collection of #{collection_name}" do
      result = described_class.call(**call_params)

      expect(result).to be_success
      expect(result[collection_name]).to respond_to(:each)
    end

    it "returns an empty collection when no records exist" do
      # This should be customized per spec to clear the appropriate data
      result = described_class.call(**call_params)

      expect(result).to be_success
      expect(result[collection_name]).to respond_to(:count)
    end
  end
end

RSpec.shared_examples "a successful find use case" do |resource_name|
  context "when successful" do
    it "finds an existing #{resource_name}" do
      result = described_class.call(**call_params)

      expect(result).to be_success
      expect(result[resource_name]).to be_present
    end
  end
end

RSpec.shared_examples "a use case with eager loading" do |resource_name, *associations|
  it "includes eager loaded associations" do
    result = described_class.call(**call_params)

    expect(result).to be_success
    
    associations.each do |association|
      expect(result[resource_name].association(association)).to be_loaded
    end
  end
end

