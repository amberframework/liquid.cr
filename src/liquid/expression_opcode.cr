module Liquid
  struct ExpressionOpCode
    enum Action
      PushVar     # Like in var
      PushLiteral # Like in "var" or 'var'
      Call        # Like in var.call
      IndexCall   # Like in var[index]
      Operator    # ==, >=, <=, <, >, !=, contains, or, and
      Filter
    end

    getter action : Action
    getter value : Any

    def initialize(@action, value : Any::Type = nil)
      @value = Any.new(value)
    end

    def inspect(io : IO)
      io << action
      unless @value.raw.nil?
        io << ' ' << (action.push_literal? ? @value.inspect : @value)
      end
      io << ';'
    end
  end
end
