require "./base"

module Liquid::Filters
  #   strip_newlines
  #
  # Removes any newline characters (line breaks) from a string.
  #
  # Input
  # {% capture string_with_newlines %}
  # Hello
  # there
  # {% endcapture %}
  #
  # {{ string_with_newlines | strip_newlines }}
  #
  # Output
  # Hellothere
  class StripNewLines
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      if data.raw.responds_to? :to_s
        Any.new data.raw.to_s.gsub /\r?\n/, ""
      else
        data
      end
    end
  end

  FilterRegister.register "strip_newlines", StripNewLines
end
