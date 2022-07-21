require "./blocks/block"

module Liquid
  abstract class Visitor
    abstract def visit(node : Node)
  end
end
