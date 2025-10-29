# frozen_string_literal: true

class MenuItemPlacementBlueprint < Blueprinter::Base
  field :id, &:menu_item_id

  field :name do |placement|
    placement.menu_item.name
  end

  field :price
end
