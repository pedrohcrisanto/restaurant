# frozen_string_literal: true

class MenuBlueprint < Blueprinter::Base
  identifier :id
  fields :name

  association :menu_item_placements, blueprint: MenuItemPlacementBlueprint, name: :items

  class << self
    def render_as_json(object, **options)
      if respond_to?(:render)
        begin
          json = call_render_safely(object, options)
          return json.is_a?(String) ? json : JSON.generate(json)
        rescue StandardError => e
          ErrorReporter.current.notify(e, context: { blueprint: self.name, method: 'render_as_json', object: safe_object_preview(object) })
          return JSON.generate(safe_render_fallback(object))
        end
      end

      JSON.generate(render_as_hash(object))
    end

    def render_as_hash(object, **options)
      parsed = if respond_to?(:render)
                 begin
                   raw = call_render_safely(object, options)
                   raw.is_a?(String) ? JSON.parse(raw) : raw
                 rescue StandardError => e
                   ErrorReporter.current.notify(e, context: { blueprint: self.name, method: 'render_as_hash', object: safe_object_preview(object) })
                   safe_render_fallback(object)
                 end
               elsif defined?(super)
                 super
               else
                 nil
               end

      result = if parsed.is_a?(Array)
                 parsed.map { |h| deep_symbolize_keys(h) }
               else
                 deep_symbolize_keys(parsed || {})
               end

      # Ensure `:items` key is present for single-menu renders even if empty
      if result.is_a?(Hash)
        result[:items] = [] unless result.key?(:items)
      end

      result
    end

    private

    # Try calling render with different argument combinations to be compatible
    # with different Blueprinter versions/signatures.
    def call_render_safely(object, options)
      begin
        render(object, **options)
      rescue ArgumentError, TypeError
        render(object)
      end
    end

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

    def deep_symbolize_keys(obj)
      case obj
      when Hash
        obj.each_with_object({}) do |(k, v), memo|
          memo[k.to_sym] = deep_symbolize_keys(v)
        end
      when Array
        obj.map { |el| deep_symbolize_keys(el) }
      else
        obj
      end
    end
  end
end
