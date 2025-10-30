# frozen_string_literal: true

class MenuItemBlueprint < Blueprinter::Base
  identifier :id
  fields :name

  class << self
    # Return a JSON string for the given object/collection
    def render_as_json(object, **options)
      # Prefer the built-in `render` (returns JSON string) when available
      if respond_to?(:render)
        json = render(object, options)
        return json.is_a?(String) ? json : JSON.generate(json)
      end

      # Fallback: build a hash and convert to JSON
      JSON.generate(render_as_hash(object))
    end

    # Return a Ruby hash for a single object (symbolized keys)
    def render_as_hash(object, **options)
      # If Blueprinter provides `render`, parse its JSON output
      if respond_to?(:render)
        parsed = JSON.parse(render(object, options))
      else
        # Try calling super if available, otherwise raise
        parsed = super if defined?(super)
      end

      # If parsed is an Array (collection), return it as-is
      if parsed.is_a?(Array)
        parsed.map { |h| h.transform_keys(&:to_sym) }
      else
        parsed.transform_keys(&:to_sym)
      end
    end
  end
end
