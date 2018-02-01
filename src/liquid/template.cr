require "./blocks"
require "./visitor"
require "./render_visitor"
require "./codegen_visitor"

module Liquid
  class Template
    getter root
    property template_path

    @root : Block::Root
    @template_path : String?

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

    def render(data, io = IO::Memory.new)
      visitor = RenderVisitor.new data, io, @template_path
      visitor.visit @root
      visitor.output
    end

    def to_code(io_name : String, io : IO = IO::Memory.new)
      visitor = CodeGenVisitor.new io
      io.puts "begin"

      io.puts <<-EOF
context = Liquid::Context.new
\{% for var in @type.instance_vars %}
    context.set \{{var.id.stringify}}, @\{{var.id}}
\{% end %}
EOF

      root.accept visitor

      io.puts "#{io_name} << Liquid::Template.new(root).render context"
      io.puts "end"
      io
    end
  end
end
