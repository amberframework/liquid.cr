require "./base"
require "inflector"

module Liquid::Filters
  # downcase
  #
  # Lowercases all characters of a string.
  #
  # Input
  # {{ "TiTlE" | downcase }}
  #
  # Output
  # title
  #
  # Another Example
  #
  # Input
  # {{ "This_Is_MY_cusTom_slug" | downcase }}
  #
  # Output
  # this_is_my_custom_slug
  class Downcase
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      if (raw = data.raw) && raw.responds_to? :downcase
        Any.new raw.downcase
      else
        data
      end
    end
  end

  # Uses the Inflector to camelize/camelcase a string.
  #
  # If the +uppercase_first_letter+ parameter is set to false, then produces
  # lowerCamelCase.
  #
  # Also converts "/" to "::" which is useful for converting
  # paths to namespaces.
  #
  #   camelize("active_model")                # => "ActiveModel"
  #   camelize("active_model", false)         # => "activeModel"
  #   camelize("active_model/errors")         # => "ActiveModel::Errors"
  #   camelize("active_model/errors", false)  # => "activeModel::Errors"
  #
  # As a rule of thumb you can think of +camelize+ as the inverse of
  # #underscore, though there are cases where that does not hold:
  #
  #   camelize(underscore("SSLError"))        # => "SslError"
  class CamelCase
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      if (raw = data.raw) && raw.is_a? String
        Any.new Inflector.camelize(raw)
      else
        data
      end
    end
  end

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

  FilterRegister.register "downcase", Downcase
  FilterRegister.register "camelcase", CamelCase
  FilterRegister.register "camelize", CamelCase
  FilterRegister.register "upcase", UpCase
  FilterRegister.register "uppercase", UpCase
end
