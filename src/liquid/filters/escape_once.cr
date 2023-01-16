require "html"
require "./base"

module Liquid::Filters
  #   escape
  #
  # Escapes a string by replacing characters with escape sequences (so that the string can be used in a URL, for example). It doesn’t change strings that don’t have anything to escape.
  #
  # Input
  # {{ "1 < 2 & 3" | escape_once }}
  #
  # Output
  # 1 &lt; 2 &amp; 3
  #
  # Input
  # {{ "1 &lt; 2 &amp; 3" | escape_once }}
  #
  # Output
  # 1 &lt; 2 &amp; 3
  class EscapeOnce
    extend Filter

    # From crystal/src/html.cr
    private SUBSTITUTIONS = {
      '&'  => "&amp;",
      '<'  => "&lt;",
      '>'  => "&gt;",
      '"'  => "&quot;",
      '\'' => "&#39;",
    }

    def self.filter(data : Any, args : Array(Any), options : Hash(String, Any)) : Any
      if data.raw.responds_to? :to_s
        str = data.to_s

        # replace all except for ampersand
        SUBSTITUTIONS.each do |key, val|
          str = str.gsub(key, val) if key != '&'
        end

        # replace all & symbol's that aren't already converted to an html entity
        # thanks http://stackoverflow.com/questions/310572/regex-in-php-to-match-that-arent-html-entities#comment18198597_311904
        str = str.gsub(/&(?!(?:[a-z][a-z\d]*|#(?:\d+|[xX][a-f\d]+));)/, "&amp;")

        Any.new str
      else
        data
      end
    end
  end

  FilterRegister.register "escape_once", EscapeOnce
end
