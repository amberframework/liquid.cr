require "./base"

module Liquid::Filters
  # upcase | uppercase
  #
  # Uppercases all characters of a string.
  #
  # Input
  # {{ "word" | upcase }}  => WORD
  # {{ "word" | uppercase }}  => WORD
  #
  class UpCase
    extend Filter

    def self.filter(data : Any, args : Array(Any), options : Hash(String, Any)?) : Any
      raise FilterArgumentException.new("upcase filter expects no arguments.") unless args.empty?

      raw = data.raw
      if raw.responds_to?(:upcase)
        Any.new(raw.upcase)
      else
        data
      end
    end
  end

  FilterRegister.register "upcase", UpCase
end
