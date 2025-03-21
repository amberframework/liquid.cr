require "./base"

module Liquid::Filters
  #   split
  #
  # Divides an input string into an array using the argument as a separator. split is commonly used to convert comma-separated items from a string to an array.
  #
  # Input
  # {% assign beatles = "John, Paul, George, Ringo" | split: ", " %}
  #
  # {% for member in beatles %}
  #   {{ member }}
  # {% endfor %}
  #
  # Output
  #   John
  #
  #   Paul
  #
  #   George
  #
  #   Ringo
  class Split
    extend Filter

    def self.filter(data : Any, args : Array(Any), options : Hash(String, Any)) : Any
      raise FilterArgumentException.new("split filter expects one argument.") if args.size != 1

      arg = args.first.to_s
      raw_data = data.raw

      return Any.new(nil) if raw_data.nil?

      if raw_data.responds_to?(:split)
        array = raw_data.split(arg).map { |obj| Any.new(obj) }
        Any.new(array)
      else
        Any{data}
      end
    end
  end

  FilterRegister.register "split", Split
end
