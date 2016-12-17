require "./block"
require "../context"

module Liquid::Block
  class Capture < BeginBlock
    REGEXP = /capture (?<varname>#{VAR})/
    @var_name : String

    def initialize(content : String)
      if match = content.strip.match REGEXP
        @var_name = match["varname"]
      else
        raise InvalidNode.new "capture block needs an argument"
      end
    end

    def render(data : Context, io)
      io_memory = IO::Memory.new
      @children.each &.render(data, io_memory)
      io_memory.close
      data.set @var_name, io_memory.to_s
    end
  end
end