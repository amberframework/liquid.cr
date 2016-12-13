require "./nodes"
require "./tokens"

include Liquid::Nodes

module Liquid
  class Template
    getter root

    @root : Root

    def initialize(@root : Root)
    end

    def render(data, io = IO::Memory.new)
      @root.render(data, io)
      io.close
      io.to_s
    end
  end
end
