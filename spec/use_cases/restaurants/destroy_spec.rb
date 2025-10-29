# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Restaurants::Destroy do
  let(:repo) { Repositories::ActiveRecord::RestaurantsRepository.new }

  it 'destroys a restaurant' do
    restaurant = create(:restaurant)
    expect {
      described_class.call(repo: repo, restaurant: restaurant)
    }.to change { Restaurant.count }.by(-1)
  end

  it 'fails when restaurant is nil' do
    result = described_class.call(repo: repo, restaurant: nil)
    expect(result).to be_failure
  end
end

