require "./blocks"

module Liquid
  # Visitor used for debug purporses
  class DebugVisitor < Visitor
    @indent = 0
    getter io : IO

    def initialize(@io : IO = IO::Memory.new)
    end

    def visit(node : Node)
      @io << " " * @indent
      node.inspect(@io)
      @io << '\n'

      @indent += 1
      node.children.each do |child|
        child.accept(self)
      end
      @indent -= 1
    end

    def visit(node : Case)
      @io << " " * @indent
      node.inspect(@io)
      @io << '\n'

      if when_arr = node.when
        when_arr.each do |when_node|
          when_node.accept(self)
        end
      end

      visit(node.else)
    end

    def visit(_nil : Nil)
    end
  end
end
