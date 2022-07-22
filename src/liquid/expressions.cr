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

      exp = Exception.new "Invalid Boolean operation: #{arr.inspect}"
      raise exp if arr.size < 3
      left = nil
      i = 1
      while i < arr.size
        left ||= arr[i - 1].as(Expression).eval(data).as_bool?
        right = arr[i + 1].as(Expression).eval(data).as_bool?

        raise exp if left.nil? || right.nil?

        op = arr[i].as BoolOperator
        left = op.call left, right
        i += 2
      end
      left.not_nil!
    end

    def initialize(content : String)
      @inner = case content.strip.downcase
               when "and", "&&" then AND
               when "or", "||"  then OR
               else
                 raise Exception.new "Invalid Boolean operation: #{content}"
               end
    end

    def call(left, right)
      @inner.call left, right
    end

    alias BoolProc = Proc(Bool, Bool, Bool)
  end

  class BinOperator(T)
    OPS = [
      "==",
      "!=",
      "<=",
      ">=",
      "<",
      ">",
      "contains",
    ]

    def self.process(operator : String, left : Any, right : Any) : Any
      self.check_operator operator

      if operator == "=="
        Any.new left.raw == right.raw
      elsif operator == "!="
        Any.new left.raw != right.raw
      elsif (left_raw = left.raw.as?(Number)) && (right_raw = right.raw.as?(Number))
        res = case operator
              when "<="
                left_raw <= right_raw
              when ">="
                left_raw >= right_raw
              when "<"
                left_raw < right_raw
              when ">"
                left_raw > right_raw
              else
                raise Exception.new "Invalid operator: #{operator}"
              end
        Any.new res
      elsif (left_t = left.as_t?) && (right_t = right.as_t?)
        res = case operator
              when "<="
                left_t <= right_t
              when ">="
                left_t >= right_t
              when "<"
                left_t < right_t
              when ">"
                left_t > right_t
              else
                raise Exception.new "Invalid operator: #{operator}"
              end
        Any.new res
      elsif (left_a = left.as_a?) && (right_a = right.as_a?)
        res = case operator
              when "contains"
                left_a.includes?(right_a)
              end
        Any.new res
      elsif (left_s = left.as_s?) && (right_s = right.as_s?)
        res = case operator
              when "<="
                left_s <= right_s
              when ">="
                left_s >= right_s
              when "<"
                left_s < right_s
              when ">"
                left_s > right_s
              when "contains"
                left_s.includes?(right_s)
              end
        Any.new res
      elsif (left_a = left.as_a?) && (right_raw = right.raw)
        res = case operator
              when "contains"
                left_a.includes?(right_raw)
              end
        Any.new res
      else
        # raise "Invalid comparison operator, can't proceed #{left} #{operator} #{right}"
        Any.new nil
      end
    end

    def self.check_operator(str : String)
      if !OPS.includes? str
        raise Exception.new "Invalid comparison operator: #{str}"
      end
    end
  end
end
