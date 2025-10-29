# frozen_string_literal: true

class Restaurant < ApplicationRecord
  has_many :menus, dependent: :destroy
  has_many :menu_item_placements, through: :menus
  has_many :menu_items, through: :menu_item_placements

  normalizes :name, with: ->(value) { value.to_s.strip.squeeze(" ") }

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  # Scopes
  scope :ordered, -> { order(:id) }
  scope :with_full_associations, -> { includes(menus: { menu_item_placements: :menu_item }) }
  scope :by_name_ci, ->(name) { where("LOWER(name) = ?", name.to_s.downcase) }
end
