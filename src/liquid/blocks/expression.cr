require "./block"
require "../filters"
require "../context"
require "../stack_machine"

module Liquid
  class ASTNode
    property child1 : ASTNode?
    property child2 : ASTNode?
  end

  class Block::Expression < Block::Node
    @stack_machine : StackMachine

    def initialize(content : String)
      @stack_machine = StackMachine.new(content)
    end

    delegate expression, to: @stack_machine

    def eval(ctx : Context) : Any
      @stack_machine.evaluate(ctx)
    end

    def inspect(io : IO)
      inspect(io) { io << @stack_machine.expression.inspect }
    end

    def_equals @stack_machine
  end
end
