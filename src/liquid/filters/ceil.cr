module Liquid::Filters
  # ceil
  # Rounds the input up to the nearest whole number.
  # Liquid tries to convert the input to a number before the filter is applied.
  # Input
  # {{ 1.2 | ceil }}
  #
  # Output
  # 2
  #
  # Input
  # {{ 2.0 | ceil }}
  #
  # Output
  # 2
  #
  # Input
  # {{ 183.357 | ceil }}
  #
  # Output
  # 184
  #
  # Here the input value is a string:
  #
  # Input
  # {{ "3.5" | ceil }}
  #
  # Output
  # 4
  class Ceil
    extend Filter

    def self.filter(data : Any, args : Array(Any), options : Hash(String, Any)) : Any
      raise FilterArgumentException.new("Unexpected argument for ceil filter") unless args.empty?

      if (raw = data.raw) && raw.is_a? Number
        Any.new(raw.ceil.to_i)
      elsif str = data.as_s?
        Any.new((str.to_i? || str.to_f? || 0).ceil.to_i)
      else
        Any.new(0)
      end
    end
  end

  FilterRegister.register "ceil", Ceil
end
