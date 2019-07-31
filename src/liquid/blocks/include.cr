require "./block"
require "../regex"

module Liquid::Block
  class Include < InlineBlock
    INCLUDE      = /^include(\s+)(?<template_name>#{STRING})(\s+with\s+(?<value>#{TYPE_OR_VAR}))?/
    INCLUDE_VARS = /\s*\,\s*(?<varname>#{VAR})\s*\:\s*(?<value>#{TYPE_OR_VAR})/

    @template_name : String
    @template_vars : Hash(String, Expression)

    getter template_name, template_vars

    def initialize(@template_name, @template_vars)
    end

    def initialize(str : String)
      if match = str.strip.match INCLUDE
        @template_vars = {} of String => Expression
        @template_name = match["template_name"].delete("\"")
        @template_name += ".liquid" if File.extname(@template_name).empty?

        if match["value"]?
          varname = File.basename(@template_name, File.extname(@template_name))
          @template_vars[varname] = Expression.new match["value"]
        elsif groups = str.strip.scan INCLUDE_VARS
          groups.each do |group|
            next if groups.empty?

            groups.each do |group|
              @template_vars[group["varname"]] = Expression.new group["value"]
            end
          end
        end
      else
        raise InvalidNode.new "Invalid assignment Node"
      end
    end
  end
end
