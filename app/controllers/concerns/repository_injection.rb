# frozen_string_literal: true

module RepositoryInjection
  extend ActiveSupport::Concern

  private

  def repository_for(resource_name)
    repository_class = "::Repositories::Persistence::#{resource_name.to_s.camelize.pluralize}Repository".constantize
    repository_class.new
  end
end
