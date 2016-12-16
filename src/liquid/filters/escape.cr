
require "html"

require "./base"

module Liquid::Filters
  #   escape
  #  
  # Escapes a string by replacing characters with escape sequences (so that the string can be used in a URL, for example). It doesn’t change strings that don’t have anything to escape.
  #  
  # Input
  # {{ "Have you read 'James & the Giant Peach'?" | escape }}
  #  
  # Output
  # Have you read &#39;James &amp; the Giant Peach&#39;?
  #  
  # Input
  # {{ "Tetsuro Takara" | escape }}
  #  
  # Output
  # Tetsuro Takara
  class Escape
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      if data.raw.responds_to? :to_s
        Any.new HTML.escape data.to_s
      else
        data
      end
    end
  end

  FilterRegister.register "escape", Escape
  
end
