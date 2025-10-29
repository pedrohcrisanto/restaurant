# frozen_string_literal: true

class Restaurant < ApplicationRecord
  has_many :menus, dependent: :destroy
  has_many :menu_item_placements, through: :menus
  has_many :menu_items, through: :menu_item_placements

  before_validation :normalize_name

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  private

  def normalize_name
    self.name = name.to_s.strip.squeeze(' ') if name
  end
end

