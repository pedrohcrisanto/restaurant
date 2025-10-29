# frozen_string_literal: true

class AddPriceToMenuItemPlacements < ActiveRecord::Migration[8.0]
  def up
    add_column :menu_item_placements, :price, :decimal, precision: 10, scale: 2, null: false, default: 0

    # Backfill price from existing menu_items.price
    execute <<~SQL.squish
      UPDATE menu_item_placements AS mip
      SET price = mi.price
      FROM menu_items AS mi
      WHERE mi.id = mip.menu_item_id;
    SQL
  end

  def down
    remove_column :menu_item_placements, :price
  end
end

