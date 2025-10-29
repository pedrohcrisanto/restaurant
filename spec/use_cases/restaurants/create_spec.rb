# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Restaurants::Create do
  let(:repo) { Repositories::ActiveRecord::RestaurantsRepository.new }

  it 'creates a restaurant with valid params' do
    result = described_class.call(repo: repo, params: { name: 'New Resto' })
    expect(result).to be_success
    expect(result[:restaurant]).to be_persisted
    expect(result[:restaurant].name).to eq('New Resto')
  end

  it 'fails with invalid params' do
    result = described_class.call(repo: repo, params: { name: '' })
    expect(result).to be_failure
  end
end

