# frozen_string_literal: true

class MenuItem < ApplicationRecord
  has_many :menu_item_placements, dependent: :destroy
  has_many :menus, through: :menu_item_placements

  normalizes :name, with: ->(value) { value.to_s.strip.squeeze(" ") }

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  # Scopes
  scope :ordered, -> { order(:id) }
  scope :by_name_ci, ->(name) { where("LOWER(name) = ?", name.to_s.downcase) }
  scope :for_restaurant, ->(restaurant) { joins(:menus).where(menus: { restaurant_id: restaurant.id }).distinct }
end
