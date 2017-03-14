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

    def escape(some : String)
      some.gsub '"', "\\\""
    end

    def visit(node : Node)
      node.children.each &.accept self
    end

    def visit(node : Raw)
      to_io %(Liquid::Block::Raw.new("#{escape node.content}"))
    end

    def visit(node : Assign)
      to_io %(Liquid::Block::Assign.new("#{escape node.varname}",
                    Liquid::Block::Expression.new("#{escape node.value.var}")))
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

    def visit(node : For)
      if node.begin && node.end
        def_to_io %(Liquid::Block::For.new("#{node.loop_var}",
                                          #{node.begin}, #{node.end}))
      else
        def_to_io "Liquid::Block::For.new(\"#{node.loop_var}\", \"#{node.loop_over}\")"
      end
      push
      node.children.each &.accept(self)
      pop
    end

    def visit(node : Expression)
      to_io %(Liquid::Block::Expression.new("#{escape node.var}"))
    end

    def visit(node : If)
      def_to_io %(Liquid::Block::Expression.new(
                   "#{escape node.if_expression.not_nil!.var}"))
      def_to_io "Liquid::Block::If.new(#{@last_var})"
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
      def_to_io "Liquid::Block::ElsIf.new( Expression.new(\"#{escape node.if_expression.var}\"))"
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
