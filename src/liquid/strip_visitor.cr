module Liquid
  class StripVisitor < Visitor
    @last_raw_node : Block::RawNode?
    @lstrip_next_raw_node = false

    private def check_strip(node : Node)
      last_raw_node = @last_raw_node
      last_raw_node.rstrip! if last_raw_node && node.lstrip?
      @lstrip_next_raw_node = node.rstrip?
    end

    def visit(node : Node)
      check_strip(node)
      node.children.each(&.accept(self))
    end

    def visit(node : If)
      check_strip(node)
      node.children.each(&.accept(self))
      node_elsif = node.elsif
      node_elsif.each(&.accept(self)) if node_elsif
      node.else.try(&.accept(self))
    end

    def visit(node : Case)
      check_strip(node)
      node.children.each(&.accept(self))
      node_when = node.when
      node_when.each(&.accept(self)) if node_when
      node.else.try(&.accept(self))
    end

    def visit(node : Block::RawNode)
      if @lstrip_next_raw_node
        node.lstrip!
        @lstrip_next_raw_node = false
      end
      @last_raw_node = node
    end
  end
end
