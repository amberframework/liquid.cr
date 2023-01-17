require "./context"
require "json"

module Liquid
  class Context
    # Set the contents of a JSON::Any to the context.
    #
    # NOTE: You need to require "liquid/json" to use this method.
    def set(var : String, json : JSON::Any) : Nil
      value = convert_json_any_to_liquid_any(json)
      set(var, value)
    end

    private def convert_json_any_to_liquid_any(json : JSON::Any) : Any
      raw = json.raw
      case raw
      when Array(JSON::Any)
        array = raw.map { |e| convert_json_any_to_liquid_any(e) }
        Any.new(array)
      when Hash(String, JSON::Any)
        hash = raw.transform_values { |e| convert_json_any_to_liquid_any(e) }
        Any.new(hash)
      else
        Any.new(raw)
      end
    end
  end
end
