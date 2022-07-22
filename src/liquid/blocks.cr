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


module Liquid
  include Liquid::Block

  BlockRegister.register "if", Liquid::Block::If
  BlockRegister.register "elsif", Liquid::Block::ElsIf, false
  BlockRegister.register "else", Liquid::Block::Else, false
  BlockRegister.register "for", Liquid::Block::For
  BlockRegister.register "capture", Liquid::Block::Capture
  BlockRegister.register "assign", Liquid::Block::Assign, false
  BlockRegister.register "increment", Liquid::Block::Increment, false
  BlockRegister.register "decrement", Liquid::Block::Decrement, false
  BlockRegister.register "include", Liquid::Block::Include, false
  BlockRegister.register "raw", Liquid::Block::Raw
  BlockRegister.register "comment", Liquid::Block::Comment
end
