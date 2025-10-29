# frozen_string_literal: true

class CreateMenuItemPlacements < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_item_placements do |t|
      t.references :menu, null: false, foreign_key: true
      t.references :menu_item, null: false, foreign_key: true
      t.timestamps
    end

    add_index :menu_item_placements, [:menu_id, :menu_item_id], unique: true, name: :index_menu_item_placements_on_menu_and_item
  end
end

