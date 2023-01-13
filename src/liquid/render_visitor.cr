require "./blocks"
require "./for_loop"

module Liquid
  class RenderVisitor < Visitor
    @data : Context
    @io : IO
    @template_path : String?

    def initialize(@data = Context.new, @io = IO::Memory.new, @template_path = nil)
    end

    @[Deprecated]
    def output
      @io.to_s
    end

    def visit(node : Case)
      value = node.expression.eval(@data)
      found = false
      if when_arr = node.when
        when_arr.each do |when_node|
          when_node.match?(@data, value).times do
            when_node.children.each &.accept(self)
            found = true
          end
        end
      end
      return if found

      else_node = node.else
      else_node.children.each(&.accept(self)) if else_node
    end

    def visit(node : If)
      if node.expression.eval(@data).raw
        node.children.each &.accept(self)
        return
      end

      elsif_arr = node.elsif
      if elsif_arr
        elsif_arr.each do |alt|
          if alt.eval(@data).raw
            alt.accept self
            return
          end
        end
      end

      node.else.try(&.accept(self))
    end

    def visit(node : Unless)
      unless node.expression.eval(@data).raw
        node.children.each &.accept(self)
        return
      end

      elsif_arr = node.elsif
      if elsif_arr
        elsif_arr.each do |alt|
          if alt.eval(@data).raw
            alt.accept self
            return
          end
        end
      end

      node.else.try(&.accept(self))
    end

    def visit(node : Node)
      node.children.each &.accept(self)
    end

    def visit(node : Assign)
      @data.set node.varname, node.value.eval(@data)
    end

    def visit(node : Block::RawNode)
      @io << node.content
    end

    def visit(node : Capture)
      io = IO::Memory.new
      visitor = RenderVisitor.new @data, io
      node.children.each &.accept visitor
      io.close
      @data.set node.var_name, io.to_s
    end

    def visit(node : Increment)
      var = @data.get node.var_name
      if var && (num = var.as_i?)
        @data.set node.var_name, num + 1
      else
        @data.set node.var_name, 1
      end
    end

    def visit(node : Decrement)
      var = @data.get node.var_name
      if var && (num = var.as_i?)
        @data.set node.var_name, num - 1
      else
        @data.set node.var_name, -1
      end
    end

    def visit(node : ExpressionNode)
      if node.children.empty?
        @io << node.eval(@data)
      else
        node.children.each &.accept(self)
      end
    end

    def visit(node : For)
      ctx = @data.dup
      loop_over_var = node.loop_over
      loop_over = if loop_over_var.is_a?(String)
                    value = Expression.new(loop_over_var).eval(ctx)
                    value.as_a? || value.as_h? || raise InvalidStatement.new "Can't iterate over #{node.loop_over}"
                  else
                    loop_over_var
                  end

      visitor = RenderVisitor.new(ctx, @io)
      parentloop = ctx["forloop"]?.try(&.raw).as?(ForLoop)
      forloop = ForLoop.new(loop_over, parentloop)

      ctx.set("forloop", forloop)
      forloop.each do |val|
        ctx.set(node.loop_var, val)
        node.children.each(&.accept(visitor))
      end
      ctx.set("forloop", parentloop)
    end

    def visit(node : Include)
      filename = if @template_path != nil
                   File.join(@template_path.not_nil!, node.template_name)
                 else
                   node.template_name
                 end

      if node.template_vars != nil
        node.template_vars.each do |key, value|
          @data.set key, value.eval(@data)
        end
      end

      template_content = File.read filename
      template = Template.parse template_content
      @io << template.render(@data)
    end
  end
end
