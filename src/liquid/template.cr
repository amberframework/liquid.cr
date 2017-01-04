require "./blocks"
require "./visitor"
require "./render_visitor"
require "./codegen_visitor"

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
      visitor = RenderVisitor.new data, io
      visitor.visit @root
      visitor.output
    end

    def to_code(io_name : String, io : IO = IO::Memory.new)
      visitor = CodeGenVisitor.new io, io_name
      io << io_name << " << \"root = Liquid::Root.new\"\n"
      root.accept visitor
      io << io_name << " << \"Liquid::Template.new root\"\n"
    end
  end
end
