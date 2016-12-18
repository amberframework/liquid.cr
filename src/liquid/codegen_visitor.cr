module Liquid
  class CodeGenVisitor < Visitor
    @io : IO
    @io_name : String
    @stack : Array(String)

    @var_count : Int32
    @last_var : String

    def initialize(@io : IO, @io_name : String)
      @stack = ["root"]
      @last_var = ""
      @var_count = 0
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
      @io << @io_name << " << " << '"' << @stack.last << " << " << some.gsub(/"/, "\\\"") << "\"\n"
    end

    def def_to_io(some : String)
      @io << @io_name << " << " << '"' << new_var << " = " << some.gsub(/"/, "\\\"") << "\"\n"
    end

    def visit(node : Node)
      node.children.each &.accept self
    end

    def visit(node : Raw)
      to_io("Raw.new(\"#{node.content}\")")
    end

    def visit(node : Assign)
      to_io("Assign.new(\"#{node.varname}\", Expression.new(\"#{node.value.var}\"))")
    end

    def visit(node : Capture)
      def_to_io("Capture.new(\"#{node.var_name}\")")
      push
      node.children.each &.accept(self)
      pop
    end

    def visit(node : For)
      if node.begin && node.end
        def_to_io "For.new(\"#{node.loop_var}\", #{node.begin}, #{node.end})"
      else
        def_to_io "For.new(\"#{node.loop_var}\", \"#{node.loop_over}\")"
      end
      push
      node.children.each &.accept(self)
      pop
    end

    def visit(node : Expression)
      to_io "Expression.new(\"#{node.var}\")"
    end

    def visit(node : If)
      def_to_io "Expression.new(\"#{node.if_expression.not_nil!.var}\")"
      def_to_io "If.new(#{@last_var})"
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
      def_to_io "ElsIf.new( Expression.new(\"#{node.if_expression.var}\"))"
      push
      node.children.each &.accept self
      pop
    end

    def visit(node : Else)
      def_to_io "Else.new"
      push
      node.children.each &.accept self
      pop
    end
  end
end
