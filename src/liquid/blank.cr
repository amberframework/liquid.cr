require "./drop"

module Liquid
  class Blank < Drop
    def ==(other : String)
      other.empty?
    end

    def ==(other : Array)
      other.empty?
    end

    def ==(other : Nil)
      true
    end

    def ==(other : Any)
      self == other.raw
    end

    def inspect(io : IO)
      io << "Liquid::Blank.new"
    end
  end
end
