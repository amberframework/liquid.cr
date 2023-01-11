require "./filters/base"
require "./filters/abs"
require "./filters/append"
require "./filters/arg_test"
require "./filters/case"
require "./filters/ceil"
require "./filters/compact"
require "./filters/date"
require "./filters/default"
require "./filters/divided_by"
require "./filters/escape"
require "./filters/escape_once"
require "./filters/first"
require "./filters/floor"
require "./filters/join"
require "./filters/last"
require "./filters/lstrip"
require "./filters/map"
require "./filters/minus"
require "./filters/modulo"
require "./filters/new_line_to_br"
require "./filters/pluralize"
require "./filters/plus"
require "./filters/prepend"
require "./filters/remove"
require "./filters/remove_first"
require "./filters/replace"
require "./filters/replace_first"
require "./filters/reverse"
require "./filters/round"
require "./filters/rstrip"
require "./filters/size"
require "./filters/slice"
require "./filters/split"
require "./filters/strip"
require "./filters/strip_html"
require "./filters/strip_newlines"
require "./filters/underscore"

require "./context"

module Liquid::Filters
  class FilterRegister
    @@register = Hash(String, Filter).new

    def self.get(str : String)
      @@register[str]?
    end

    def self.register(name, filter)
      @@register[name] = filter
    end
  end

  FilterRegister.register "capitalize", Capitalize

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

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      if (raw = data.raw) && raw.responds_to? :capitalize
        Any.new raw.capitalize
      else
        data
      end
    end
  end
end
