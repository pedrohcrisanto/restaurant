# frozen_string_literal: true

class MenuItemPlacementBlueprint < Blueprinter::Base
  field :id, &:menu_item_id

  field :name do |placement|
    placement.menu_item.name
  end

  field :price

  class << self
    def render_as_json(object, **options)
      if respond_to?(:render)
        json = render(object, options)
        return json.is_a?(String) ? json : JSON.generate(json)
      end

      JSON.generate(render_as_hash(object))
    end

    def render_as_hash(object, **options)
      if respond_to?(:render)
        parsed = JSON.parse(render(object, options))
      else
        parsed = super if defined?(super)
      end

      if parsed.is_a?(Array)
        parsed.map { |h| h.transform_keys(&:to_sym) }
      else
        parsed.transform_keys(&:to_sym)
      end
    end
  end
end
