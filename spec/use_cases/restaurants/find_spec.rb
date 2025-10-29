# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Restaurants::Find do
  let(:repo) { Repositories::ActiveRecord::RestaurantsRepository.new }

  it 'finds an existing restaurant' do
    restaurant = create(:restaurant)
    result = described_class.call(repo: repo, id: restaurant.id)
    expect(result).to be_success
    expect(result[:restaurant].id).to eq(restaurant.id)
  end

  it 'fails when restaurant is not found' do
    result = described_class.call(repo: repo, id: 0)
    expect(result).to be_failure
  end
end

