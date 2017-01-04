require "./blocks/block"
require "./blocks/if"
require "./blocks/else"
require "./blocks/elsif"
require "./blocks/assign"
require "./blocks/expression"
require "./blocks/raw"
require "./blocks/for"
require "./blocks/capture"
require "./blocks/increment"
# require "./blocks/decrement"

include Liquid::Block

module Liquid
  BlockRegister.register "if", If
  BlockRegister.register "elsif", ElsIf, false
  BlockRegister.register "else", Else, false
  BlockRegister.register "for", For
  BlockRegister.register "capture", Capture
  BlockRegister.register "assign", Assign, false
  BlockRegister.register "increment", Increment, false
  #  BlockRegister.register "decrement", Decrement, false
end
