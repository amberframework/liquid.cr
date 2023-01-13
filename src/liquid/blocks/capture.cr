require "./block"

module Liquid::Block
  class Capture < BeginBlock
    getter var_name : String

    def initialize(content @var_name)
    end
  end
end
