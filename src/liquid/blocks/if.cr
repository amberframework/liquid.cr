require "./conditional"

module Liquid::Block
  class If < Conditional
    def expression_from_content(content : String) : Expression
      match = content.match(/^\s*if (?<expr>.+)\s*$/)
      raise InvalidNode.new("Invalid if node") if match.nil?

      Expression.new(match["expr"])
    end
  end
end
