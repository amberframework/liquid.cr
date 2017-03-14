require "./blocks"

module Liquid
  class RenderVisitor < Visitor
    @data : Context
    @io : IO

    def initialize
      @data = Context.new
      @io = IO::Memory.new
    end

    def initialize(@data : Context)
      @io = IO::Memory.new
    end

    def initialize(@data : Context, @io : IO)
    end

    def output
      @io.close
      @io.to_s
    end

    def visit(node : If)
      if node.if_expression.not_nil!.eval(@data).raw
        node.children.each &.accept(self)
      else
        found = false
        if elsif_arr = node.elsif
          elsif_arr.each do |alt|
            if alt.eval(@data).raw
              found = true
              alt.accept self
              break
            end
          end
        end
        if !found && (else_alt = node.else)
          else_alt.accept self
        end
      end
    end

    def visit(node : Node)
      node.children.each &.accept(self)
    end

    def visit(node : Assign)
      @data.set node.varname, node.value.eval(@data)
    end

    def visit(node : Raw)
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

    def visit(node : Expression)
      if node.children.empty?
        @io << node.eval(@data)
      else
        node.children.each &.accept(self)
      end
    end

    def visit(node : Filtered)
      matches = node.raw.scan GFILTER
      if matches.first["filter"] == node.first.var ||
         "\"#{matches.first["filter"]}\"" == node.first.var
        matches.shift
      end
      matches.each do |fm|
        if filter = Filters::FilterRegister.get fm["filter"]
          args : Array(Expression)?
          args = nil
          if (margs = fm["args"]?)
            args = Array(Expression).new
            splitted = margs.split(',').map &.strip
            splitted.each { |m| args << Expression.new(m) }
          end
          node.filters << {filter, args}
        else
          raise InvalidExpression.new "Filter #{fm["filter"]} is not registered."
        end
      end

      result : Any
      result = node.first.eval @data
      node.filters.each do |tuple|
        args = tuple[1].not_nil!.map &.eval(@data) if tuple[1]
        result = tuple[0].filter(result, args)
      end
      @io << result
    end

    def visit(node : Boolean)
      @io << (node.inner ? "true" : "false")
    end

    def visit(node : For)
      data = @data.dup
      if node.begin && node.end
        render_with_range node, data
      elsif node.loop_over
        render_with_var node, data
      else
        raise InvalidStatement.new "Can't iterate over #{node.loop_over}"
      end
    end

    def visit(node : Include)
      template_content = File.read node.template_name
      template = Template.parse(template_content)
      @io << template.render(@data)
    end

    private def render_with_range(node : For, data : Context)
      i = 0
      visitor = RenderVisitor.new data, @io
      start = node.begin.as(Int32)
      stop = node.end.as(Int32)
      start.upto stop do |x|
        data.set node.loop_var, x
        data.set "loop.index", i + 1
        data.set "loop.index0", i
        data.set "loop.revindex", stop - start - i + 1
        data.set "loop.revindex0", stop - start - i
        data.set "loop.first", x == start
        data.set "loop.last", x == stop
        data.set "loop.length", stop - start
        node.children.each &.accept(visitor)
        i += 1
      end
    end

    private def render_with_var(node : For, data : Context)
      val = Expression.new node.loop_over.not_nil!
      if (arr = val.eval(data).as_a?)
        visitor = RenderVisitor.new data, @io
        i = 0
        stop = arr.size
        arr.each do |val|
          data.set node.loop_var, val
          data.set "loop.index", i + 1
          data.set "loop.index0", i
          data.set "loop.revindex", stop - i + 1
          data.set "loop.revindex0", stop - i
          data.set "loop.first", i == 0
          data.set "loop.last", i == stop
          data.set "loop.length", stop
          node.children.each &.accept(visitor)
          i += 1
        end
      else
        raise InvalidStatement.new "Can't iterate over #{node.loop_over}"
      end
    end
  end
end
