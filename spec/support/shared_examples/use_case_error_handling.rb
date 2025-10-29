# frozen_string_literal: true

# Shared examples for use case error handling
# Usage:
#   it_behaves_like "a use case with error handling", "use_case_name", error_method: :some_method, error_args: { arg: value }

RSpec.shared_examples "a use case with error handling" do |use_case_name, options = {}|
  context "when an error occurs" do
    let(:error_method) { options[:error_method] || :save }
    let(:error_args) { options[:error_args] || {} }
    let(:repo_double) { options[:repo] || repo }

    it "handles exceptions and returns failure" do
      allow(repo_double).to receive(error_method).and_raise(StandardError, "Database error")

      result = described_class.call(**call_params.merge(error_args))

      expect(result).to be_failure
      expect(result[:error]).to eq(I18n.t("errors.unexpected_error"))
    end

    it "notifies error reporter with context" do
      allow(repo_double).to receive(error_method).and_raise(StandardError, "Database error")
      
      expected_context = { use_case: use_case_name }.merge(options[:context] || {})
      
      expect(ErrorReporter.current).to receive(:notify).with(
        instance_of(StandardError),
        context: expected_context
      )

      described_class.call(**call_params.merge(error_args))
    end
  end
end

# Shared examples for use case with repository error handling
RSpec.shared_examples "a use case with repository error" do |use_case_name, repo_method|
  context "when repository raises an error" do
    it "handles the error and returns failure" do
      allow(repo).to receive(repo_method).and_raise(StandardError, "Repository error")

      result = described_class.call(**call_params)

      expect(result).to be_failure
      expect(result[:error]).to eq(I18n.t("errors.unexpected_error"))
    end

    it "notifies error reporter" do
      allow(repo).to receive(repo_method).and_raise(StandardError, "Repository error")
      
      expect(ErrorReporter.current).to receive(:notify).with(
        instance_of(StandardError),
        context: hash_including(use_case: use_case_name)
      )

      described_class.call(**call_params)
    end
  end
end

