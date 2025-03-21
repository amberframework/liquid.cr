require "./base"

module Liquid::Filters
  # floor
  #
  # floors a string or float value and returns the value floor'd
  #
  # Input
  # {{ "1.34" | floor }}
  #
  # Output
  # 1.0
  class Floor
    extend Filter

    def self.filter(data : Any, args : Array(Any), options : Hash(String, Any)) : Any
      raise FilterArgumentException.new("Unexpected argument for floor filter") unless args.empty?

      if (raw = data.raw) && raw.is_a? Number
        Any.new(raw.floor.to_i)
      elsif str = data.as_s?
        Any.new((str.to_i? || str.to_f? || 0).floor.to_i)
      else
        Any.new(0)
      end
    end
  end

  FilterRegister.register "floor", Floor
end
