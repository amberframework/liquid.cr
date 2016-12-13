require "./node"
require "../context"

module Liquid::Nodes
  # Inside of a for-loop block, you can access some special variables:
  # Variable      	Description
  # loop.index 	    The current iteration of the loop. (1 indexed)
  # loop.index0   	The current iteration of the loop. (0 indexed)
  # loop.revindex 	The number of iterations from the end of the loop (1 indexed)
  # loop.revindex0 	The number of iterations from the end of the loop (0 indexed)
  # loop.first    	True if first iteration.
  # loop.last     	True if last iteration.
  # loop.length    	The number of items in the sequence.
  class For < Node
    GLOBAL = /for (?<var>\w+) in (?<range>.+)/
    RANGE  = /(?<start>[0-9]+)\.\.(?<end>[0-9]+)/

    @loop_var : String
    @loop_over : String?
    @begin : Int32?
    @end : Int32?

    def initialize(token : Tokens::ForStatement)
      if gmatch = token.content.match GLOBAL
        @loop_var = gmatch["var"]
        if rmatch = gmatch["range"].match RANGE
          @begin = rmatch["start"].to_i
          @end = rmatch["end"].to_i
        elsif (rmatch = gmatch["range"].match /^\s*(?<varname>#{VAR})\s*$/)
          @loop_over = rmatch["varname"]
        else
          raise InvalidNode.new "Invalid for node : #{token.content}"
        end
      else
          raise InvalidNode.new "Invalid for node : #{token.content}"
      end
    end

    def render_with_range(data, io)
      i = 0
      start = @begin.as(Int32)
      stop = @end.as(Int32)
      start.upto stop do |x|
        data.set(@loop_var, x)
        data.set("loop.index", i + 1)
        data.set("loop.index0", i)
        data.set("loop.revindex", stop - start - i + 1)
        data.set("loop.revindex0", stop - start - i)
        data.set("loop.first", x == start)
        data.set("loop.last", x == stop)
        data.set("loop.length", stop - start)
        children.each &.render(data, io)
        i += 1
      end
    end

    def render_with_var(data, io)
      val = Expression.new @loop_over.not_nil!
      if (arr = val.eval(data)) && arr.is_a? Array
        i = 0
        stop = arr.size
        arr.each do |val|
          data.set(@loop_var, val)
          data.set("loop.index", i + 1)
          data.set("loop.index0", i)
          data.set("loop.revindex", stop - i + 1)
          data.set("loop.revindex0", stop - i)
          data.set("loop.first", i == 0)
          data.set("loop.last", i == stop)
          data.set("loop.length", stop)
          children.each &.render(data, io)
          i += 1
        end
      else
        raise InvalidStatement.new "Can't iterate over #{@loop_over}"
      end
    end

    def render(data, io)
      data = Context.new data
      if @begin.is_a?(Int32) && @end.is_a?(Int32)
        render_with_range data, io
      elsif @loop_over.is_a?(String)
        render_with_var data, io
      else
        raise InvalidStatement.new "Can't iterate over #{@loop_over}"
      end
    end
  end
end