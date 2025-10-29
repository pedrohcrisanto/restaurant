# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MenuItemPlacement, type: :model do
  subject { build(:menu_item_placement) }

  it { is_expected.to belong_to(:menu) }
  it { is_expected.to belong_to(:menu_item) }

  it { is_expected.to validate_uniqueness_of(:menu_id).scoped_to(:menu_item_id) }
  it { is_expected.to validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
end

