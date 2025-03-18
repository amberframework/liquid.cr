require "./base"

module Liquid::Filters
  # Filter abs
  #
  # Returns the absolute value of a number.
  #
  # `{{ -17 | abs }}` => `17`
  #
  # `{{ 4 | abs }}` => `4`
  #
  # abs will also work on a string if the string only contains a number.
  #
  # `{{ "-19.86" | abs }}` => `19.86`
  class Abs
    extend Filter

    def self.filter(data : Any, args : Array(Any), options : Hash(String, Any)) : Any
      raise FilterArgumentException.new("Unexpected argument for abs filter") unless args.empty?

      if data.raw.is_a? Number
        Any.new data.raw.as(Number).abs
      elsif str = data.as_s?
        Any.new((str.to_i? || str.to_f? || 0).abs)
      else
        Any.new(0)
      end
    end
  end

  FilterRegister.register "abs", Abs
end
