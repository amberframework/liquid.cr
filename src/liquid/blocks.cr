require "./blocks/assign"
require "./blocks/block"
require "./blocks/capture"
require "./blocks/comment"
require "./blocks/decrement"
require "./blocks/else"
require "./blocks/elsif"
require "./blocks/expression"
require "./blocks/for"
require "./blocks/if"
require "./blocks/include"
require "./blocks/increment"
require "./blocks/raw"

include Liquid::Block

module Liquid
  BlockRegister.register "if", If
  BlockRegister.register "elsif", ElsIf, false
  BlockRegister.register "else", Else, false
  BlockRegister.register "for", For
  BlockRegister.register "capture", Capture
  BlockRegister.register "assign", Assign, false
  BlockRegister.register "increment", Increment, false
  BlockRegister.register "decrement", Decrement, false
  BlockRegister.register "include", Include, false
  BlockRegister.register "raw", Raw
  BlockRegister.register "comment", Comment
end
