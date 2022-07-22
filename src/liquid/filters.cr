require "./filters/base"
require "./filters/arg_test"
require "./filters/case"
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

  FilterRegister.register "abs", Abs
  FilterRegister.register "append", Append
  FilterRegister.register "capitalize", Capitalize
  FilterRegister.register "ceil", Ceil

  # ceil
  # Rounds the input up to the nearest whole number.
  # Liquid tries to convert the input to a number before the filter is applied.
  # Input
  # {{ 1.2 | ceil }}
  #
  # Output
  # 2
  #
  # Input
  # {{ 2.0 | ceil }}
  #
  # Output
  # 2
  #
  # Input
  # {{ 183.357 | ceil }}
  #
  # Output
  # 184
  #
  # Here the input value is a string:
  #
  # Input
  # {{ "3.5" | ceil }}
  #
  # Output
  # 4
  class Ceil
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      if (raw = data.raw) && raw.is_a? Number
        Any.new raw.ceil
      elsif (str = data.as_s?) && (flt = str.to_f32?)
        Any.new flt.ceil
      else
        data
      end
    end
  end

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

  # Filter abs
  #
  # Returns the absolute value of a number.
  #
  # `{{ -17 | abs }}` => `17`
  #
  # `{{ 4 | abs }}` => `4`
  #
  # abs will also work on a string if the string only contains a number.
  #
  # `{{ "-19.86" | abs }}` => `19.86`
  class Abs
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      if data.raw.is_a? Number
        Any.new data.raw.as(Number).abs
      elsif (str = data.as_s?) && (flt = str.to_f32?)
        Any.new flt.abs
      else
        data
      end
    end
  end

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
      if (d = data.as_s?) && args && args.size == 1 && (arg = args.first.as_s?)
        Any.new d + arg
      else
        data
      end
    end
  end
end
