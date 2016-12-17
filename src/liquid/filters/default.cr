require "./base"
require "../context"

module Liquid::Filters
  # default
  #
  # Allows you to specify a fallback in case a value doesn’t exist. default will show its value if the left side is nil, false, or empty.
  #
  # In this example, product_price is not defined, so the default value is used.
  #
  # Input
  # {{ product_price | default: 2.99 }}
  #
  # Output
  # 2.99
  #
  # In this example, product_price is defined, so the default value is not used.
  #
  # Input
  # {% assign product_price = 4.99 %}
  # {{ product_price | default: 2.99 }}
  #
  # Output
  # 4.99
  #
  # In this example, product_price is empty, so the default value is used.
  #
  # Input
  # {% assign product_price = "" %}
  # {{ product_price | default: 2.99 }}
  #
  # Output
  # 2.99
  class Default
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      raise FilterArgumentException.new "default filter expects one argument" unless args && args.first?

      if !data.raw || ((r = data.raw) && r.responds_to?(:empty?) && r.empty?)
        args.first
      else
        data
      end
    end
  end

  FilterRegister.register "default", Default
end
