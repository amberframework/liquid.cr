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

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      if (raw = data.raw) && raw.is_a? String
        Any.new raw.as(String).upcase
      else
        data
      end
    end
  end

  FilterRegister.register "upcase", UpCase
end
