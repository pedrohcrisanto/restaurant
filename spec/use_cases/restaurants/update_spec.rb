# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Restaurants::Update do
  let(:repo) { Repositories::ActiveRecord::RestaurantsRepository.new }

  it 'updates a restaurant with valid params' do
    restaurant = create(:restaurant)
    result = described_class.call(repo: repo, restaurant: restaurant, params: { name: 'Updated' })
    expect(result).to be_success
    expect(result[:restaurant].reload.name).to eq('Updated')
  end

  it 'fails with invalid params' do
    restaurant = create(:restaurant)
    result = described_class.call(repo: repo, restaurant: restaurant, params: { name: '' })
    expect(result).to be_failure
  end
end

