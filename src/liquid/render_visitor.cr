require "./blocks"

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
      value = node.case_expression.not_nil!.eval(@data).raw
      if when_arr = node.when
        when_arr.each do |when_node|
          if when_node.eval(value)
            when_node.children.each &.accept(self)
            return
          end
        end
      end
      if else_node = node.else
        else_node.children.each &.accept(self)
      end
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

    def visit(node : Block::Raw)
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
        if (filter_name = Filters::FilterRegister.get fm["filter"])
          filter_args : Array(Expression)? = nil
          if (margs = fm["args"]?)
            filter_args = Array(Expression).new
            if margs.match(/^#{FILTER_ARGS}$/)
              while margs =~ /^(#{FILTER_ARG})/
                match = $1
                filter_args << Expression.new(match)
                margs = margs.sub(match, "")
                margs = margs.sub(/^\s*,\s*/, "")
              end
            end
          end
          node.filters << {filter_name, filter_args}
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

        # for compatibility with Shopify liquid
        data.set "forloop.length", stop - start
        data.set "forloop.index", i + 1
        data.set "forloop.index0", i
        data.set "forloop.rindex", stop - start - i + 1
        data.set "forloop.rindex0", stop - start - i
        data.set "forloop.first", x == start
        data.set "forloop.last", x == stop
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

          # for compatibility with Shopify liquid
          data.set "forloop.length", stop
          data.set "forloop.index", i + 1
          data.set "forloop.index0", i
          data.set "forloop.rindex", stop - i + 1
          data.set "forloop.rindex0", stop - i
          data.set "forloop.first", i == 0
          data.set "forloop.last", i == stop
          node.children.each &.accept(visitor)
          i += 1
        end
      elsif (hash = val.eval(data).as_h?)
        visitor = RenderVisitor.new data, @io
        i = 0
        stop = hash.keys.size
        hash.each do |k, v|
          val = [Any.new(k), v]
          data.set node.loop_var, val
          data.set "loop.index", i + 1
          data.set "loop.index0", i
          data.set "loop.revindex", stop - i + 1
          data.set "loop.revindex0", stop - i
          data.set "loop.first", i == 0
          data.set "loop.last", i == stop
          data.set "loop.length", stop

          # for compatibility with Shopify liquid
          data.set "forloop.length", stop
          data.set "forloop.index", i + 1
          data.set "forloop.index0", i
          data.set "forloop.rindex", stop - i + 1
          data.set "forloop.rindex0", stop - i
          data.set "forloop.first", i == 0
          data.set "forloop.last", i == stop
          node.children.each &.accept(visitor)
          i += 1
        end
      else
        raise InvalidStatement.new "Can't iterate over #{node.loop_over}"
      end
    end
  end
end
