# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Repositories::ActiveRecord::RestaurantsRepository do
  subject(:repo) { described_class.new }

  describe '#relation_for_index' do
    it 'returns ordered relation including nested associations' do
      r1 = create(:restaurant)
      r2 = create(:restaurant)
      create(:menu, restaurant: r1)
      rel = repo.relation_for_index
      expect(rel).to be_a(ActiveRecord::Relation)
      expect(rel.order_values).to include(:id)
      expect(rel.first).to be_a(Restaurant)
    end
  end

  describe '#find' do
    it 'returns record with eager-loaded associations' do
      restaurant = create(:restaurant)
      menu = create(:menu, restaurant: restaurant)
      found = repo.find(restaurant.id)
      expect(found).to be_present
      expect(found.menus.map(&:id)).to include(menu.id)
    end
  end

  describe '#build/#save/#update/#destroy' do
    it 'creates, updates and destroys' do
      record = repo.build(name: 'Repo R')
      expect(repo.save(record)).to be_truthy
      expect(record).to be_persisted

      expect(repo.update(record, name: 'Repo R2')).to be_truthy
      expect(record.reload.name).to eq('Repo R2')

      expect { repo.destroy(record) }.to change { Restaurant.count }.by(-1)
    end
  end
end

