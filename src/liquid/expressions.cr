require "./context"

module Liquid
  enum ExpressionType
    BOOL,
    STRING,
    INT,
    VAR,
    ASSIGN
  end

  class BoolOperator

    AND = BoolProc.new { |l, r| l && r }
    OR = BoolProc.new { |l, r| l || r }

    @inner : BoolProc

    def self.process(arr : Array(Expression | BoolOperator), data) : Bool
      left : Bool
      right : Bool
      proc : BoolOperator

      exp = Exception.new "Invalid Boolean operation"
      raise exp if arr.first.is_a? BoolOperator
      arr.each_index do |i|
        raise exp if (i % 2 == 0 && arr[i].is_a? BoolOperator) || (i % 2 == 1 && arr[i].is_a? Expression)
      end
      
      l = arr.pop.as(Expression).eval(data)
      if l.is_a? Bool
        left = l
        right = false
      else
        raise exp
      end

      arr.each do |a|
        case a
        when Expression
          right = a.eval(data).as Bool
        when BoolOperator
          left = a.call left, right
        end
      end

      left
    end

    def initialize(str : String)
      @inner = case str
               when "and" then AND
               when "or" then OR
               else
                 raise Exception.new "Invalid Boolean operation"
               end
    end

    def call(left, right)
      @inner.call left, right
    end

    alias BoolProc = Proc(Bool, Bool, Bool)

  end

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
