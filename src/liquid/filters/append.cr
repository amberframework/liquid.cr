require "./base"

module Liquid::Filters
  # append
  #
  # Concatenates two strings and returns the concatenated value.
  #
  # Input
  # {{ "/my/fancy/url" | append: ".html" }}
  #
  # Output
  # /my/fancy/url.html
  #
  # append can also be used with variables:
  #
  # Input
  # {% assign filename = "/index.html" %}
  # {{ "website.com" | append: filename }}
  #
  # Output
  # website.com/index.html
  class Append
    extend Filter

    def self.filter(data : Any, args : Array(Any), options : Hash(String, Any)) : Any
      raise LiquidException.new("Missing argument for append filter") if args.nil? || args.empty?
      raise LiquidException.new("Too many arguments for append filter") if args.size > 1

      Any.new(data.to_s + args.first.to_s)
    end
  end

  FilterRegister.register "append", Append
end
