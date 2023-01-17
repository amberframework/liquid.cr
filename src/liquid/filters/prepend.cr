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

    def self.filter(data : Any, args : Array(Any), options : Hash(String, Any)) : Any
      return data if args.nil? || args.empty?

      Any.new(args.first.to_s + data.to_s)
    end
  end

  FilterRegister.register "prepend", Prepend
end
