require "./blocks"

module Liquid
  class Template
    getter root

    @root : Block::Root

    def self.parse(str : String) : Template
      Parser.parse(str)
    end

    def initialize(@root : Block::Root)
    end

    def render(data, io = IO::Memory.new)
      @root.render(data, io)
      io.close
      io.to_s
    end
  end
end
