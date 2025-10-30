# frozen_string_literal: true

class Menu < ApplicationRecord
  belongs_to :restaurant

  has_many :menu_item_placements, dependent: :destroy
  has_many :menu_items, through: :menu_item_placements

  normalizes :name, with: ->(value) { value.to_s.strip.squeeze(" ") }

  validates :name, presence: true, uniqueness: { scope: :restaurant_id, case_sensitive: false }

  # Scopes
  scope :ordered, -> { order(:id) }
  scope :with_items, -> { eager_load(menu_item_placements: :menu_item) }
  scope :by_name_ci, ->(name) { where("LOWER(name) = ?", name.to_s.downcase) }
end
