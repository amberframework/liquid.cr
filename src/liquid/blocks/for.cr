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
    GLOBAL  = /(?<var>\w+) in (?<range>.+)/
    RANGE   = /(?<start>[0-9]+)\.\.(?<end>[0-9]+)/
    VARNAME = /^\s*(?<varname>#{VAR})\s*$/

    getter loop_var : String
    getter loop_over : String | Range(Int32, Int32)

    def initialize(@loop_var, begin s, end e)
      @loop_over = s..e
    end

    def initialize(@loop_var, @loop_over)
    end

    def initialize(content : String)
      if gmatch = content.match(GLOBAL)
        @loop_var = gmatch["var"]
        @loop_over = if rmatch = gmatch["range"].match(RANGE)
                       rmatch["start"].to_i..rmatch["end"].to_i
                     elsif rmatch = gmatch["range"].match VARNAME
                       rmatch["varname"]
                     else
                       raise SyntaxError.new("Invalid for node: #{content}.")
                     end
      else
        raise SyntaxError.new("Invalid for node: #{content}.")
      end
    end

    def inspect(io : IO)
      inspect(io) do
        io << @loop_var.inspect
        loop_over = @loop_over
        io << " in " << loop_over.inspect if loop_over
      end
    end
  end
end
