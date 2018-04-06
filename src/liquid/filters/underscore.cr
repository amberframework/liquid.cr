require "./base"
require "inflector"

module Liquid::Filters
  # underscore
  #
  # Uses the Inflector to underscore a string.
  #
  # Input
  # {{ "ActiveModel" | underscore }}
  #
  # Output
  # active_model
  class Underscore
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      if (raw = data.raw) && raw.is_a? String
        Any.new Inflector.underscore(raw)
      else
        data
      end
    end
  end

  FilterRegister.register "underscore", Underscore
end
