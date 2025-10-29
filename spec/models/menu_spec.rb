# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Menu, type: :model do
  subject { build(:menu) }

  it { is_expected.to belong_to(:restaurant) }
  it { is_expected.to have_many(:menu_item_placements).dependent(:destroy) }
  it { is_expected.to have_many(:menu_items).through(:menu_item_placements) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:restaurant_id).case_insensitive }
end

