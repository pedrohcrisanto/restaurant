# frozen_string_literal: true

class MenuItemPlacement < ApplicationRecord
  belongs_to :menu
  belongs_to :menu_item

  validates :menu_id, uniqueness: { scope: :menu_item_id }
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  private
end

