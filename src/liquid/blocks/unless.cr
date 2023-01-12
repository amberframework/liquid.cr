require "./conditional"

module Liquid::Block
  class Unless < Conditional
    def expression_from_content(content : String) : Expression
      match = content.match(/^\s*unless (?<expr>.+)\s*$/)
      raise InvalidNode.new("Invalid unless node") if match.nil?

      Expression.new(match["expr"])
    end
  end
end
