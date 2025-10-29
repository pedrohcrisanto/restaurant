# frozen_string_literal: true

class RestaurantBlueprint < Blueprinter::Base
  identifier :id
  fields :name

  association :menus, blueprint: MenuBlueprint
end

