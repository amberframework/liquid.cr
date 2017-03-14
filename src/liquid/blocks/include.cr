require "./block"
require "../regex"

module Liquid::Block
  class Include < InlineBlock
    INCLUDE = /^include(\s+)(?<template_name>#{STRING})/

    @template_name : String

    getter template_name

    def initialize(@template_name)
    end

    def initialize(str : String)
      if match = str.strip.match INCLUDE
        @template_name = match["template_name"].delete("\"")
      else
        raise InvalidNode.new "Invalid assignment Node"
      end
    end
  end
end
