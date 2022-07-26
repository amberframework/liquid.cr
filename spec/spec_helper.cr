require "spec"
require "../src/liquid"

include Liquid

def node_output(node : Node, ctx : Context)
  v = RenderVisitor.new ctx, IO::Memory.new
  node.accept v
  v.output
end
