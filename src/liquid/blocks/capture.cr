require "./block"

module Liquid::Block
  class Capture < BeginBlock
    getter var_name : String

    def initialize(content @var_name)
      raise SyntaxError.new if @var_name !~ VARIABLE_SIGNATURE
    end
  end
end
