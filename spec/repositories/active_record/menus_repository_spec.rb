# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Repositories::ActiveRecord::MenusRepository do
  subject(:repo) { described_class.new }

  let!(:restaurant) { create(:restaurant) }

  describe '#relation_for_restaurant' do
    it 'returns ordered relation including placements and items' do
      create(:menu, restaurant: restaurant)
      rel = repo.relation_for_restaurant(restaurant)
      expect(rel).to be_a(ActiveRecord::Relation)
      expect(rel.order_values).to include(:id)
      expect(rel.first).to be_a(Menu)
    end
  end

  describe '#find_for_restaurant' do
    it 'returns only menus belonging to the restaurant' do
      menu = create(:menu, restaurant: restaurant)
      other_menu = create(:menu) # different restaurant
      found = repo.find_for_restaurant(restaurant, menu.id)
      expect(found).to be_present
      expect(found.id).to eq(menu.id)
      expect(found.id).not_to eq(other_menu.id)
    end
  end

  describe 'build/save/update/destroy' do
    it 'creates, updates and destroys a menu' do
      record = repo.build_for_restaurant(restaurant, name: 'Repo Menu')
      expect(repo.save(record)).to be_truthy
      expect(record).to be_persisted

      expect(repo.update(record, name: 'Repo Menu 2')).to be_truthy
      expect(record.reload.name).to eq('Repo Menu 2')

      expect { repo.destroy(record) }.to change { Menu.count }.by(-1)
    end
  end
end

