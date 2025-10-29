# frozen_string_literal: true

class RemovePriceFromMenuItems < ActiveRecord::Migration[8.0]
  def up
    remove_column :menu_items, :price, :decimal, precision: 10, scale: 2, null: false, default: 0
  end

  def down
    add_column :menu_items, :price, :decimal, precision: 10, scale: 2, null: false, default: 0
  end
end

