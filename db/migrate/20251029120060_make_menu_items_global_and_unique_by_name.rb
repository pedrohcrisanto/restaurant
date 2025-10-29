# frozen_string_literal: true

class MakeMenuItemsGlobalAndUniqueByName < ActiveRecord::Migration[8.0]
  def up
    # Drop composite unique indexes based on restaurant_id
    remove_index :menu_items, name: :index_menu_items_on_restaurant_id_and_name, if_exists: true

    execute <<~SQL.squish
      DROP INDEX IF EXISTS index_menu_items_on_restaurant_id_and_lower_name;
    SQL

    # Remove restaurant_id (and FK) from menu_items
    if column_exists?(:menu_items, :restaurant_id)
      remove_reference :menu_items, :restaurant, foreign_key: true
    end

    # Add case-insensitive unique index on lower(name)
    execute <<~SQL.squish
      CREATE UNIQUE INDEX IF NOT EXISTS index_menu_items_on_lower_name
      ON menu_items (LOWER(name));
    SQL
  end

  def down
    # Remove global unique index
    execute <<~SQL.squish
      DROP INDEX IF EXISTS index_menu_items_on_lower_name;
    SQL

    # Re-add restaurant_id and original indexes
    add_reference :menu_items, :restaurant, foreign_key: true

    add_index :menu_items, [:restaurant_id, :name], unique: true, name: :index_menu_items_on_restaurant_id_and_name

    execute <<~SQL.squish
      CREATE UNIQUE INDEX IF NOT EXISTS index_menu_items_on_restaurant_id_and_lower_name
      ON menu_items (restaurant_id, LOWER(name));
    SQL
  end
end

