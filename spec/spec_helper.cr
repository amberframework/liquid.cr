require "spec"
require "../src/liquid"

include Liquid

def node_output(node : Node, ctx : Context = Context.new) : String
  io = IO::Memory.new
  v = RenderVisitor.new(ctx, io)
  node.accept(v)
  io.to_s
end
