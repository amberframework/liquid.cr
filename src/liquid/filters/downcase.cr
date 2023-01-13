require "./base"

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

  FilterRegister.register "downcase", Downcase
end
