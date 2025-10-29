# frozen_string_literal: true

class CreateMenuItems < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_items do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.string :name, null: false
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0
      t.timestamps
    end

    add_index :menu_items, [:restaurant_id, :name], unique: true, name: :index_menu_items_on_restaurant_id_and_name

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          CREATE UNIQUE INDEX IF NOT EXISTS index_menu_items_on_restaurant_id_and_lower_name
          ON menu_items (restaurant_id, LOWER(name));
        SQL
      end
      dir.down do
        execute <<~SQL.squish
          DROP INDEX IF EXISTS index_menu_items_on_restaurant_id_and_lower_name;
        SQL
      end
    end
  end
end

