require "./base"

module Liquid::Filters
  # prepend
  #
  # Concatenates two strings and returns the concatenated value with the main value
  # at the end.
  #
  # Input
  # {{ "/index.html" | prepend: "/my/fancy/url" }}
  #
  # Output
  # /my/fancy/index.html
  #
  # prepend can also be used with variables:
  #
  # Input
  # {% assign domain_path = "www.example.com" %}
  # {{ "/index.html" | prepend: domain_path }}
  #
  # Output
  # www.example.com/index.html
  class Prepend
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      if (d = data.as_s?) && args && args.size == 1 && (arg = args.first.as_s?)
        Any.new arg + d
      else
        data
      end
    end
  end

  FilterRegister.register "prepend", Prepend
end
