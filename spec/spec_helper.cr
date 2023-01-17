require "spec"
require "../src/liquid"
require "../src/liquid/debug_visitor"

include Liquid

def node_output(node : Node, ctx : Context = Context.new) : String
  io = IO::Memory.new
  v = RenderVisitor.new(ctx, io)
  node.accept(v)
  io.to_s
end

def it_renders(template : String, expected : String, ctx = Context.new, file = __FILE__, line = __LINE__)
  template_as_title = template.size < 64 ? template : "#{template[0..60]}…"

  it "renders #{template_as_title} as #{expected}", file: file, line: line do
    Parser.parse(template).render(ctx).should eq(expected)
  end
end

def debug_node(node : Node)
  v = DebugVisitor.new
  node.accept(v)
  puts v.io.to_s.colorize.green
end
