require "./visitor"

module Liquid
  class CodeGenVisitor < Visitor
    @io : IO
    @stack : Array(String)

    @var_count : Int32
    @last_var : String

    def initialize(@io : IO)
      @stack = ["root"]
      @last_var = ""
      @var_count = 0
      @io << "root = Liquid::Block::Root.new\n"
    end

    def output
      @io.close
      @io.to_s
    end

    def new_var
      @var_count += 1
      @last_var = "var#{@var_count}"
    end

    def push
      @stack << @last_var
    end

    def pop
      to_io @stack.pop
    end

    def to_io(some : String)
      @io << @stack.last << " << " << some << "\n"
    end

    def def_to_io(some : String)
      @io << new_var << " = " << some << "\n"
    end

    def escape(text : String) : String
      CodeGenVisitor.escape(text)
    end

    def self.escape(text : String) : String
      text.gsub do |char|
        case char
        when '"'  then "\\\""
        when '\n' then "\\n"
        when '\r' then "\\r"
        when '\t' then "\\t"
        else
          char
        end
      end
    end

    def visit(node : Node)
      node.children.each &.accept self
    end

    def visit(node : Block::RawNode)
      to_io %(Liquid::Block::RawNode.new("#{escape node.content}"))
    end

    def visit(node : Assign)
      to_io %(Liquid::Block::Assign.new("#{escape node.varname}", Liquid::Expression.new("#{escape node.value.expression}")))
    end

    def visit(node : Include)
      to_io %(Liquid::Block::Include.new("#{escape node.template_name}"))
    end

    def visit(node : Capture)
      def_to_io %(Liquid::Block::Capture.new("#{escape node.var_name}"))
      push
      node.children.each &.accept(self)
      pop
    end

    def visit(node : Case)
      def_to_io %(Liquid::Block::Case.new("#{escape node.expression.expression}"))
      push
      node.children.each &.accept self
      if arr = node.when
        arr.each &.accept self
      end
      if e = node.else
        e.accept self
      end
      pop
    end

    def visit(node : When)
      expressions = node.when_expressions.map do |expression|
        escape(expression.expression)
      end
      def_to_io %(Liquid::Block::When.new("#{expressions.join(", ")}"))
      push
      node.children.each &.accept(self)
      pop
    end

    def visit(node : For)
      def_to_io %(Liquid::Block::For.new("#{node.loop_var}", #{node.loop_over.inspect}))
      push
      node.children.each &.accept(self)
      pop
    end

    def visit(node : ExpressionNode)
      to_io %(Liquid::Block::ExpressionNode.new("#{escape node.expression}"))
    end

    def visit(node : If)
      def_to_io %(Liquid::Block::If.new("#{escape node.expression.expression}"))
      push
      node.children.each &.accept self
      if arr = node.elsif
        arr.each &.accept self
      end
      if e = node.else
        e.accept self
      end
      pop
    end

    def visit(node : Unless)
      def_to_io %(Liquid::Block::Unless.new("#{escape node.expression.expression}"))
      push
      node.children.each &.accept self
      if arr = node.elsif
        arr.each &.accept self
      end
      if e = node.else
        e.accept self
      end
      pop
    end

    def visit(node : ElsIf)
      def_to_io %(Liquid::Block::ElsIf.new("#{escape node.expression.expression}"))
      push
      node.children.each &.accept self
      pop
    end

    def visit(node : Else)
      def_to_io "Liquid::Block::Else.new"
      push
      node.children.each &.accept self
      pop
    end
  end
end
