# frozen_string_literal: true

class MenuItemPlacementBlueprint < Blueprinter::Base
  field :id do |placement|
    placement.menu_item_id
  end

  field :name do |placement|
    placement.menu_item.name
  end

  field :price
end

