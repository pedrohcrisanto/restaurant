# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Restaurants::List do
  let(:repo) { Repositories::ActiveRecord::RestaurantsRepository.new }

  it 'returns a relation with restaurants' do
    create_list(:restaurant, 3)
    result = described_class.call(repo: repo)
    expect(result).to be_success
    relation = result[:relation]
    expect(relation).to be_a(ActiveRecord::Relation)
    expect(relation.count).to be >= 3
  end
end

