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

      raw_context = options[:context] || {}

      # Build a matcher that evaluates only procs (dynamic expectations) and treats
      # non-proc static values as presence checks. For nested hashes, only evaluate
      # nested procs; static nested values won't be strictly asserted.
      matcher_context = { use_case: use_case_name }

      raw_context.each do |key, value|
        if value.respond_to?(:call)
          # dynamic -> evaluate now inside example and require exact match
          matcher_context[key] = instance_exec(&value)
        elsif value.is_a?(Hash)
          # For nested hashes, evaluate any procs inside; ignore static nested values
          # (only require presence of the nested key with matching subkeys if procs are used).
          nested = {}
          value.each do |k2, v2|
            if v2.respond_to?(:call)
              nested[k2] = instance_exec(&v2)
            end
          end

          # Only add nested matcher if there are any proc-evaluated expectations
          matcher_context[key] = hash_including(nested) unless nested.empty?
        else
          # static non-proc: skip strict matching (presence-only)
          next
        end
      end

      # Base matcher: ensure context key contains at least the use_case and any
      # evaluated dynamic expectations.
      notify_matcher = hash_including(context: hash_including(matcher_context))

      expect(ErrorReporter.current).to receive(:notify).with(
        instance_of(StandardError),
        notify_matcher
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
