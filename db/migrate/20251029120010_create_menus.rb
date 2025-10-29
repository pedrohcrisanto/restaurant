# frozen_string_literal: true

class CreateMenus < ActiveRecord::Migration[8.0]
  def change
    create_table :menus do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.string :name, null: false
      t.timestamps
    end

    add_index :menus, [:restaurant_id, :name], unique: true, name: :index_menus_on_restaurant_id_and_name

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          CREATE UNIQUE INDEX IF NOT EXISTS index_menus_on_restaurant_id_and_lower_name
          ON menus (restaurant_id, LOWER(name));
        SQL
      end
      dir.down do
        execute <<~SQL.squish
          DROP INDEX IF EXISTS index_menus_on_restaurant_id_and_lower_name;
        SQL
      end
    end
  end
end

