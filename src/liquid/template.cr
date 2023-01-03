require "./blocks"
require "./visitor"
require "./render_visitor"
require "./codegen_visitor"

module Liquid
  class Template
    getter root : Block::Root
    property template_path : String?

    def self.parse(str : String) : Template
      Parser.parse(str)
    end

    def self.parse(file : File) : Template
      Parser.parse(file)
    end

    def initialize(@root : Block::Root)
    end

    def initialize(@root : Block::Root, @template_path : String)
    end

    def render(data, io : IO) : Nil
      visitor = RenderVisitor.new data, io, @template_path
      visitor.visit @root
    end

    def render(ctx : Context) : String
      io = IO::Memory.new
      render(ctx, io)
      io.to_s
    end

    def to_code(io_name : String, io : IO = IO::Memory.new, context : String? = nil)
      visitor = CodeGenVisitor.new io
      io.puts "begin"

      unless context
        context = "context"
        io.puts <<-EOF
context = Liquid::Context.new
{% for var in @type.instance_vars %}
    context.set {{var.id.stringify}}, @{{var.id}}
{% end %}
EOF
      end

      root.accept visitor

      io.puts "#{io_name} << Liquid::Template.new(root).render #{context}"
      io.puts "end"
      io
    end
  end
end
