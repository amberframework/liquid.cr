require "./block"
require "../context"

module Liquid::Block
  # Inside of a for-loop block, you can access some special variables:
  # Variable      	Description
  # loop.index 	    The current iteration of the loop. (1 indexed)
  # loop.index0   	The current iteration of the loop. (0 indexed)
  # loop.revindex 	The number of iterations from the end of the loop (1 indexed)
  # loop.revindex0 	The number of iterations from the end of the loop (0 indexed)
  # loop.first    	True if first iteration.
  # loop.last     	True if last iteration.
  # loop.length    	The number of items in the sequence.
  class For < BeginBlock
    GLOBAL  = /for (?<var>\w+) in (?<range>.+)/
    RANGE   = /(?<start>[0-9]+)\.\.(?<end>[0-9]+)/
    VARNAME = /^\s*(?<varname>#{VAR})\s*$/

    getter loop_var, loop_over, :begin, :end
    @loop_var : String
    @loop_over : String?
    @begin : Int32?
    @end : Int32?

    def initialize(@loop_var, @begin, @end)
    end

    def initialize(@loop_var, @loop_over)
    end

    def initialize(content : String)
      if gmatch = content.match(GLOBAL)
        @loop_var = gmatch["var"]
        if rmatch = gmatch["range"].match RANGE
          @begin = rmatch["start"].to_i
          @end = rmatch["end"].to_i
        elsif (rmatch = gmatch["range"].match VARNAME)
          @loop_over = rmatch["varname"]
        else
          raise InvalidNode.new "Invalid for node : #{content}"
        end
      else
        raise InvalidNode.new "Invalid for node : #{content}"
      end
    end
  end
end
