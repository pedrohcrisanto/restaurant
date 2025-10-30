# frozen_string_literal: true

class RestaurantBlueprint < Blueprinter::Base
  identifier :id
  fields :name

  association :menus, blueprint: MenuBlueprint

  class << self
    def render_as_json(object, **options)
      if respond_to?(:render)
        json = call_render_safely(object, options)
        return json.is_a?(String) ? json : JSON.generate(json)
      end

      JSON.generate(render_as_hash(object))
    end

    def render_as_hash(object, **options)
      if respond_to?(:render)
        raw = call_render_safely(object, options)
        parsed = raw.is_a?(String) ? JSON.parse(raw) : raw
      else
        parsed = super if defined?(super)
      end

      if parsed.is_a?(Array)
        parsed.map { |h| deep_symbolize_keys(h) }
      else
        deep_symbolize_keys(parsed)
      end
    end

    private

    # Try calling render with different argument combinations to be compatible
    # with different Blueprinter versions/signatures.
    def call_render_safely(object, options)
      r = method(:render)
      params = r.parameters.map(&:first)

      # If method accepts keyword args (or keyrest), try object + options
      if params.any? { |p| [:key, :keyreq, :keyrest].include?(p) }
        return r.call(object, **options)
      end

      # If method accepts a positional argument, call with object
      if params.any? { |p| [:req, :opt].include?(p) }
        return r.call(object)
      end

      # Fallback: if method accepts no args, call without args
      return r.call if params.empty?

      # Last resort: try calling with object+options and let it surface errors
      r.call(object, **options)
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
