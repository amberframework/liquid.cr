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
      if (raw = data.raw) && raw.responds_to?(:split) &&
         args && (fa = args.first?) && (arg = fa.as_s?)
        Any.new(raw.split(arg).map { |s| Any.new(s) })
      else
        data
      end
    end
  end

  FilterRegister.register "split", Split
end
