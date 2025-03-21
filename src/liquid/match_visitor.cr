require "./blocks"

module Liquid
  class MatchVisitor < Visitor
    def visit(node : Node) : String
      node.children.map { |e| self.visit e }.join
    end

    def visit(node : Block::RawNode) : String
      node.content
    end

    def visit(node : ExpressionNode)
      ".*"
    end

    def visit(node : Conditional) : String
      child_nodes = [node.children.map { |e| self.visit e }.join]

      if elsif_arr = node.elsif
        elsif_arr.each do |alt|
          child_nodes << self.visit alt
        end
      end

      if else_arr = node.else
        child_nodes << self.visit else_arr
      else
        child_nodes << ""
      end

      "(#{child_nodes.join("|")})"
    end

    def visit(node : Case)
      child_nodes = [] of String

      if when_arr = node.when
        when_arr.each do |when_node|
          child_nodes << self.visit when_node
        end
      end

      if else_arr = node.else
        child_nodes << self.visit else_arr
      else
        child_nodes << ""
      end

      "(#{child_nodes.join("|")})"
    end

    def visit(node : For)
      child_nodes = node.children.map { |e| self.visit e }

      "(#{child_nodes.join})*"
    end
  end
end
