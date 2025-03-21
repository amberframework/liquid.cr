module Liquid::Filters
  # capitalize
  #
  # Makes the first character of a string capitalized.
  #
  # Input
  # {{ "title" | capitalize }}
  #
  # Output
  # Title
  #
  # capitalize only capitalizes the first character of the string, so later words are not affected:
  #
  # Input
  # {{ "my great title" | capitalize }}
  #
  # Output
  # My great title
  class Capitalize
    extend Filter

    def self.filter(data : Any, args : Array(Any), options : Hash(String, Any)) : Any
      raise FilterArgumentException.new("Unexpected argument for capitalize filter") unless args.empty?

      raw = data.raw
      if raw.is_a?(String)
        Any.new(raw.capitalize)
      else
        data
      end
    end
  end

  FilterRegister.register "capitalize", Capitalize
end
