require "./block"
require "../regex"
require "../block_register"

module Liquid::Block
  class Assign < InlineBlock
    ASSIGN = /^assign (?<varname>#{VAR}) ?= ?(?<value>#{TYPE_OR_VAR})$/

    @varname : String
    @value : Expression

    getter varname, value

    def initialize(@varname, @value)
    end

    def initialize(str : String)
      if match = str.strip.match ASSIGN
        @varname = match["varname"]
        @value = Expression.new match["value"]
      else
        raise InvalidNode.new "Invalid assignment Node"
      end
    end
  end
end
