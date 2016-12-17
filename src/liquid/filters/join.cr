require "./base"

module Liquid::Filters
  # join
  #
  # Combines the items in an array into a single string using the argument as a separator.
  #
  # Input
  # {% assign beatles = "John, Paul, George, Ringo" | split: ", " %}
  #
  # {{ beatles | join: " and " }}
  #
  # Output
  # John and Paul and George and Ringo
  class Join
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      if args && (tmp = args.first?) && (arg = tmp.as_s?) && (d = data.as_a?)
        Any.new d.join(arg)
      else
        data
      end
    end
  end

  FilterRegister.register "join", Join
end
