require "./blocks"
require "./visitor"
require "./render_visitor"

module Liquid
  class Template
    getter root

    @root : Block::Root

    def self.parse(str : String) : Template
      Parser.parse(str)
    end

    def initialize(@root : Block::Root)
    end

    def render(data, io = IO::Memory.new)
      visitor =  RenderVisitor.new data, io
      visitor.visit @root
      visitor.output
    end
  end
end
