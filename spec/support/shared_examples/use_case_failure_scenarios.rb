# frozen_string_literal: true

# Shared examples for common use case failure scenarios
# Usage:
#   it_behaves_like "a use case with validation failures", :restaurant
#   it_behaves_like "a use case with not found error", :restaurant

RSpec.shared_examples "a use case with validation failures" do |resource_name|
  context "when validation fails" do
    it "fails with blank name" do
      params_with_blank = call_params.dup
      params_with_blank[:params] = { name: "" }

      result = described_class.call(**params_with_blank)

      expect(result).to be_failure
      expect(result.type).to eq(:invalid)
      expect(result[:error]).to be_present
    end

    it "fails with duplicate name" do
      # This should be customized per spec to create the duplicate
      # Example implementation - override in specific specs if needed
      if defined?(create_duplicate)
        create_duplicate

        result = described_class.call(**call_params)

        expect(result).to be_failure
        expect(result.type).to eq(:invalid)
        expect(result[:error]).to include(/already been taken/i)
      end
    end

    it "fails with nil name" do
      params_with_nil = call_params.dup
      params_with_nil[:params] = { name: nil }

      result = described_class.call(**params_with_nil)

      expect(result).to be_failure
      expect(result[:error]).to be_present
    end
  end
end

RSpec.shared_examples "a use case with not found error" do |resource_name|
  context "when #{resource_name} is not found" do
    it "returns failure with not_found error" do
      params_with_invalid_id = call_params.dup
      params_with_invalid_id[:id] = 999_999

      result = described_class.call(**params_with_invalid_id)

      expect(result).to be_failure
      expect(result.type).to eq(:not_found)
      expect(result[:error]).to eq(I18n.t("errors.#{resource_name.to_s.pluralize}.not_found"))
    end
  end
end

RSpec.shared_examples "a use case with scoped not found error" do |resource_name, scope_name|
  context "when #{resource_name} belongs to another #{scope_name}" do
    it "returns failure with not_found error" do
      # This should be customized per spec
      # Example: create resource for different scope and try to access it
      result = described_class.call(**call_params)

      expect(result).to be_failure
      expect(result.type).to eq(:not_found)
    end
  end
end

