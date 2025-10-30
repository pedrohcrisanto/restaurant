# frozen_string_literal: true

class MenuItemPlacementBlueprint < Blueprinter::Base
  field :id, &:menu_item_id

  field :name do |placement|
    placement.menu_item&.name
  end

  field :price do |placement|
    # Ensure price is serialized as string with minimal formatting
    # Handle nil price gracefully
    p = placement.price
    p.nil? ? nil : p.to_s
  end

  class << self
    # Serialize to JSON; accepts single object or array
    def render_as_json(object, **_options)
      JSON.generate(render_as_hash(object))
    rescue StandardError => e
      ErrorReporter.current.notify(e, context: { blueprint: self.name, method: 'render_as_json', object: safe_object_preview(object) })
      JSON.generate(safe_render_fallback(object))
    end

    # Return a hash (or array of hashes) representing the placement(s).
    def render_as_hash(object, **_options)
      if object.respond_to?(:to_ary)
        object.to_ary.map { |placement| placement_hash(placement) }
      elsif object.is_a?(Enumerable)
        object.map { |placement| placement_hash(placement) }
      else
        placement_hash(object)
      end
    rescue StandardError => e
      ErrorReporter.current.notify(e, context: { blueprint: self.name, method: 'render_as_hash', object: safe_object_preview(object) })
      safe_render_fallback(object)
    end

    def placement_hash(placement)
      return {} unless placement

      {
        id: placement.menu_item_id,
        name: placement.menu_item&.name,
        price: placement.price.nil? ? nil : placement.price.to_s
      }
    end

    private

    def safe_render_fallback(object)
      object.respond_to?(:to_ary) || object.is_a?(Enumerable) ? [] : {}
    end

    def safe_object_preview(object)
      sample = object.respond_to?(:to_ary) ? object.first : object
      if sample.respond_to?(:inspect)
        sample.inspect[0..500]
      else
        sample.class.name
      end
    end
  end
end
