require "./context"

module Liquid
  class BinOperator
    macro responds_to(l, o, r)
      if {{l.id}}.responds_to?(:{{o.id}})
        {{l.id}} {{o.id}} {{r.id}}
      else
        raise InvalidExpression.new "{{l.id}} can't be compared with {{r.id}}"
      end
    end

    EQ  = BinProc.new { |left, right| left == right }
    NE  = BinProc.new { |left, right| left != right }
    LE  = BinProc.new { |left, right| responds_to(left, :<=, right) }
    GE  = BinProc.new { |left, right| responds_to(left, :>=, right) }
    LT  = BinProc.new { |left, right| responds_to(left, :<, right) }
    GT  = BinProc.new { |left, right| responds_to(left, :>, right) }
    NOP = BinProc.new { false }

    @inner : BinProc

    def initialize(str : String)
      @inner = case str
               when "==" then EQ
               when "!=" then NE
               when "<=" then LE
               when ">=" then GE
               when "<"  then LT
               when ">"  then GT
               else
                 NOP
               end
    end

    def call(left : Context::DataType, right : Context::DataType)
      @inner.call left.as(Context::DataType), right.as(Context::DataType)
    end

    alias BinProc = Proc(Context::DataType, Context::DataType, Bool)
  end
end
