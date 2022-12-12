module Liquid
  struct StackMachineOpCode
    getter action : Action
    getter! value : String?

    def initialize(@action, @value = nil)
    end

    def to_s(io : IO)
      io << action
      io << '(' << @value << ')' if @value
      io << ';'
    end
  end
end
