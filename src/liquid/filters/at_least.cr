require "./base"

module Liquid::Filters
  # Filter at_least
  #
  # Limits a number to a minimum value.
  #
  # `{{ 4 | at_least: 5 }}` => `5`
  #
  # `{{ 4 | at_least: 3 }}` => `4`
  class AtLeast
    extend Filter

    def self.filter(data : Any, args : Array(Any), options : Hash(String, Any)) : Any
      raise FilterArgumentException.new("at_least filter expects one argument.") if args.size != 1

      min_value = args.first.as_number_or_zero
      result = data.as_number_or_zero
      result = min_value if min_value > result

      Any.new(result)
    end
  end

  FilterRegister.register "at_least", AtLeast
end
