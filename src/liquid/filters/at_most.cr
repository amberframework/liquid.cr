require "./base"

module Liquid::Filters
  # Filter at_most
  #
  # Limits a number to a maximum value.
  #
  # `{{ 4 | at_most: 5 }}` => `4`
  #
  # `{{ 4 | at_most: 3 }}` => `3`
  class AtMost
    extend Filter

    def self.filter(data : Any, args : Array(Any), options : Hash(String, Any)) : Any
      raise FilterArgumentException.new("at_most filter expects one argument.") if args.size != 1

      max_value = args.first.as_number
      result = data.as_number
      result = max_value if result > max_value

      Any.new(result)
    end
  end

  FilterRegister.register "at_most", AtMost
end
