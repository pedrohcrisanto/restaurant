# frozen_string_literal: true

class MenuBlueprint < Blueprinter::Base
  identifier :id
  fields :name

  association :menu_item_placements, blueprint: MenuItemPlacementBlueprint, name: :items
end

