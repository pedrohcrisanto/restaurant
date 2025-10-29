# frozen_string_literal: true

class MenuItem < ApplicationRecord

  has_many :menu_item_placements, dependent: :destroy
  has_many :menus, through: :menu_item_placements

  before_validation :normalize_name

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  private

  def normalize_name
    self.name = name.to_s.strip.squeeze(' ') if name
  end
end

