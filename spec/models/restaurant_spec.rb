# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  subject { build(:restaurant) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }

  it { is_expected.to have_many(:menus).dependent(:destroy) }
  it { is_expected.to have_many(:menu_item_placements).through(:menus) }
  it { is_expected.to have_many(:menu_items).through(:menu_item_placements) }
end

