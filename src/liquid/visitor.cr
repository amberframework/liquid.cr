require "./blocks/block"

module Liquid
  abstract class Visitor
    abstract def visit(n : Node)
  end
end
