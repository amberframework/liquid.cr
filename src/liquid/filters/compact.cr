require "./base"

module Liquid::Filters
  class Compact
    extend Filter

    def self.filter(data : Any, args : Array(Any), options : Hash(String, Any)) : Any
      raise FilterArgumentException.new("compact filter expects at most 1 argument.") if args.size > 1

      raw_data = data.raw
      return Any.new(nil) if raw_data.nil?
      return Any{data} unless raw_data.is_a?(Enumerable(Any))

      key = args.first?
      return Any.new(raw_data.reject(&.raw.nil?)) if key.nil? || !key.as_s?

      key = key.as_s
      result = raw_data.reject do |item|
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
