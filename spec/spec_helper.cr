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

def debug_node(node : Node)
  v = DebugVisitor.new
  node.accept(v)
  puts v.io.to_s.colorize.green
end
