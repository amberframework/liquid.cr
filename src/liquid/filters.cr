require "./filters/base"
require "./filters/abs"
require "./filters/append"
require "./filters/arg_test"
require "./filters/capitalize"
require "./filters/ceil"
require "./filters/compact"
require "./filters/date"
require "./filters/default"
require "./filters/divided_by"
require "./filters/downcase"
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
require "./filters/upcase"

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
end
