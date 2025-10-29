# frozen_string_literal: true

# Shared examples for use case input validations
# Usage:
#   it_behaves_like "a use case with repository validation"
#   it_behaves_like "a use case with params validation"
#   it_behaves_like "a use case with resource validation", :restaurant

RSpec.shared_examples "a use case with repository validation" do
  context "when repository is missing" do
    it "returns failure" do
      params_without_repo = call_params.dup
      params_without_repo[:repo] = nil

      result = described_class.call(**params_without_repo)

      expect(result).to be_failure
      expect(result[:error]).to be_present
    end
  end
end

RSpec.shared_examples "a use case with params validation" do
  context "when params are missing" do
    it "returns failure" do
      params_without_params = call_params.dup
      params_without_params[:params] = nil

      result = described_class.call(**params_without_params)

      expect(result).to be_failure
      expect(result[:error]).to be_present
    end
  end
end

RSpec.shared_examples "a use case with resource validation" do |resource_name|
  context "when #{resource_name} is nil" do
    it "returns failure with not_found error" do
      params_without_resource = call_params.dup
      params_without_resource[resource_name] = nil

      result = described_class.call(**params_without_resource)

      expect(result).to be_failure
      expect(result.type).to eq(:not_found)
      expect(result[:error]).to eq(I18n.t("errors.#{resource_name.to_s.pluralize}.not_found"))
    end
  end
end

RSpec.shared_examples "a use case with id validation" do
  context "when id is missing" do
    it "returns failure" do
      params_without_id = call_params.dup
      params_without_id[:id] = nil

      result = described_class.call(**params_without_id)

      expect(result).to be_failure
      expect(result[:error]).to be_present
    end
  end
end

RSpec.shared_examples "a use case with name validation" do
  context "when name is blank" do
    it "returns failure" do
      params_with_blank_name = call_params.dup
      params_with_blank_name[:params] = { name: "" }

      result = described_class.call(**params_with_blank_name)

      expect(result).to be_failure
      expect(result.type).to eq(:invalid)
      expect(result[:error]).to be_present
    end
  end

  context "when name is nil" do
    it "returns failure" do
      params_with_nil_name = call_params.dup
      params_with_nil_name[:params] = { name: nil }

      result = described_class.call(**params_with_nil_name)

      expect(result).to be_failure
      expect(result[:error]).to be_present
    end
  end
end

