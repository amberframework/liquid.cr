require "./context"

module Liquid
  class BoolOperator
    AND = BoolProc.new { |l, r| l && r }
    OR  = BoolProc.new { |l, r| l || r }

    @inner : BoolProc

    def self.process(arr : Array(Expression | BoolOperator), data) : Bool
      left : Bool?
      right : Bool?
      proc : BoolOperator

      exp = Exception.new "Invalid Boolean operation "
      raise exp if arr.size < 3 || arr.first.is_a? BoolOperator
      arr.each_index do |i|
        raise exp if (i % 2 == 0 && arr[i].is_a? BoolOperator) || (i % 2 == 1 && arr[i].is_a? Expression)
      end
      left = nil
      i = 1
      while i < arr.size
        left ||= arr[i - 1].as(Expression).eval(data).as?(Bool)
        right = arr[i + 1].as(Expression).eval(data).as?(Bool)

        raise exp if left.nil? || right.nil?

        op = arr[i].as BoolOperator
        left = op.call left, right
        i += 2
      end
      left.not_nil!
    end

    def initialize(str : String)
      @inner = case str
               when "and" then AND
               when "or"  then OR
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

    EQ = BinProc.new { |left, right| left == right }
    NE = BinProc.new { |left, right| left != right }
    LE = BinProc.new { |left, right| responds_to(left, :<=, right) }
    GE = BinProc.new { |left, right| responds_to(left, :>=, right) }
    LT = BinProc.new { |left, right| responds_to(left, :<, right) }
    GT = BinProc.new { |left, right| responds_to(left, :>, right) }

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
                 raise Exception.new "Invalid comparison operator : #{str}"
               end
    end

    def call(left : Context::DataType, right : Context::DataType)
      @inner.call left.as(Context::DataType), right.as(Context::DataType)
    end

    alias BinProc = Proc(Context::DataType, Context::DataType, Bool)
  end
end
