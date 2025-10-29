# frozen_string_literal: true

class CreateRestaurants < ActiveRecord::Migration[8.0]
  def change
    create_table :restaurants do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_index :restaurants, :name, unique: true, name: :index_restaurants_on_name

    # Functional unique index for case-insensitive name (PostgreSQL)
    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          CREATE UNIQUE INDEX IF NOT EXISTS index_restaurants_on_lower_name
          ON restaurants (LOWER(name));
        SQL
      end
      dir.down do
        execute <<~SQL.squish
          DROP INDEX IF EXISTS index_restaurants_on_lower_name;
        SQL
      end
    end
  end
end

