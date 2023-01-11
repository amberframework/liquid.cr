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

    def self.filter(data : Any, args : Array(Any)?) : Any
      return data if args.nil? || args.empty?

      Any.new(data.to_s + args.first.to_s)
    end
  end

  FilterRegister.register "append", Append
end
