# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MenuItem, type: :model do
  subject { build(:menu_item) }

  it { is_expected.to have_many(:menu_item_placements).dependent(:destroy) }
  it { is_expected.to have_many(:menus).through(:menu_item_placements) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
end

