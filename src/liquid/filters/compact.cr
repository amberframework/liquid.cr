require "./base"

module Liquid::Filters
  class Compact
    extend Filter

    def self.filter(data : Any, args : Array(Any), options : Hash(String, Any)) : Any
      raise FilterArgumentException.new("compact filter expects at most 1 argument.") if args.size > 1

      array = data.as_a?
      return data if array.nil?

      key = args.first?
      return Any.new(array.reject(&.raw.nil?)) if key.nil? || !key.as_s?

      key = key.as_s
      result = array.reject do |item|
        raw_item = item.raw
        if raw_item.is_a?(Drop) || raw_item.is_a?(Hash)
          raw_item[key].raw.nil?
        else
          raw_item.nil?
        end
      end
      Any.new(result)
    end
  end

  FilterRegister.register "compact", Compact
end
