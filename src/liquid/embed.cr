require "./context"

module Liquid
  macro embed(filename)
    \{{run "./liquid/process", {{filename}}}}
  end

  module View
    macro liquid_to_s( filename )
      def to_s(io : IO)
        context = Liquid::Context.new
        \{% for var in @type.instance_vars %}
          context.set \{{var.id.stringify}}, \{{var}}
        \{% end %}
        template = Liquid.embed({{filename}})
        io << template.render context
      end
    end
  end
end
