require "./base"

module Liquid::Filters
  # Takes either an array of hash's or a Hash and attempts to grab the first property value
  # of said hash or the property of all the hashes in the array and returns an array value
  class Map
    extend Filter

    def self.filter(data : Any, args : Array(Any), options : Hash(String, Any)) : Any
      # raise error if user doesn't provide an argument to divided by
      raise FilterArgumentException.new "map filter expects one argument" unless args && args.first?

      # raise error if user doesn't provide a string argument
      raise FilterArgumentException.new "map filter expects argument to be a string" unless args.first.raw.is_a?(String)

      if (raw = data.raw) && raw.is_a?(Array) && (first = args.first?)
        result = raw.compact_map { |obj| self.responds_to(obj, first.as_s) }
        if result.empty?
          data
        else
          Any.new(result)
        end
      elsif (raw = data.raw) && raw.is_a?(Hash) && (first = args.first?)
        raw[first.as_s]
      else
        data
      end
    end

    def self.responds_to(data, key)
      if data = data.as_h?
        data[key]?
      else
        nil
      end
    end
  end

  FilterRegister.register "map", Map
end
