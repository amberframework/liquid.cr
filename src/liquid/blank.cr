require "./drop"

module Liquid
  class Blank < Drop
    def ==(str : String)
      str.empty?
    end

    def ==(array : Array)
      array.empty?
    end

    def ==(_nil : Nil)
      true
    end

    def ==(other : Any)
      self == other.raw
    end
  end
end
