require "./base"
require "inflector"

module Liquid::Filters
  # pluralize
  #
  # Uses the Inflector to pluralize a string.
  #
  # Input
  # {{ "post" | pluralize }}
  #
  # Output
  # posts
  class Pluralize
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      if (raw = data.raw) && raw.is_a? String
        Any.new Inflector.pluralize(raw)
      else
        data
      end
    end
  end

  FilterRegister.register "pluralize", Pluralize
end
