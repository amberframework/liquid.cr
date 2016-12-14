require "./node"
require "./expression"

module Liquid::Nodes
  class Assign < Node
    ASSIGN = /^assign (?<varname>#{VAR}) ?= ?(?<value>#{TYPE_OR_VAR})$/

    @varname : String
    @value : Expression

    def initialize(tok : Tokens::AssignStatement)
      if match = tok.content.strip.match ASSIGN
        @varname = match["varname"]
        @value = Expression.new match["value"]
        raise InvalidNode.new "Invalid variable name" if @varname.match /true|false/
      else
        raise InvalidNode.new "Invalid assignment Node"
      end
    end

    def initialize(str : String)
      if match = str.strip.match ASSIGN
        @varname = match["varname"]
        @value = Expression.new match["value"]
      else
        raise InvalidNode.new "Invalid assignment Node"
      end
    end

    def render(data, io)
      data.set @varname, @value.eval(data)
    end
  end
end
