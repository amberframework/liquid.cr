require "spec"
require "../src/liquid"

def node_output(node : Node, ctx : Context)
  io = IO::Memory.new
  node.render ctx, io
  io.close
  io.to_s
end
