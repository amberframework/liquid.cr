require "./block"
require "../filters"
require "../context"
require "../regex"

module Liquid::Block
  abstract class AbstractExpression < Node
  end

  class Filtered < AbstractExpression
    getter filters, first, raw
    @raw : String
    @first : Expression
    @filters : Array(Tuple(Filters::Filter, Array(Expression)?))

    def initialize(str)
      @raw = str
      if match = str.match GFILTERED
        @first = Expression.new match["first"]
        @filters = Array(Tuple(Filters::Filter, Array(Expression)?)).new
      else
        raise InvalidExpression.new "Invalid filter use :#{str}"
      end
    end
  end

  class Boolean < AbstractExpression
    getter inner
    @inner : Bool

    def initialize(str)
      if match(str)
        @inner = str == "true"
      else
        raise Exception.new "Invalid Boolean expression : #{str}"
      end
    end

    def match(str : String) : Regex::MatchData?
      str.match /^false$|^true$/
    end
  end

  class Expression < AbstractExpression
    getter var
    @var : String

    def initialize(var)
      @var = var.strip
      pre_cache
    end

    def pre_cache
      @children << Boolean.new @var if @var == "true" || @var == "false"
      if m = @var.match GSTRING
        @children << Block::Raw.new m["str"]
      end
      if @var.match intern(FILTERED)
        @children << Filtered.new @var
      end
    end

    private def intern(re)
      /^#{re}$/
    end

    def eval(data) : Any
      ret = if @var == "true" || @var == "false"
              @var == "true"
            elsif m = @var.match GSTRING
              m["str"]
            elsif m = @var.match intern(GINT)
              m["intval"].to_i
            elsif m = @var.match intern(GFLOAT)
              m["floatval"].to_f32
            elsif @var.match intern(VAR)
              data.get(@var)
            elsif m = @var.match intern(GCMP)
              le = Expression.new(m["left"]).eval data
              re = Expression.new(m["right"]).eval data
              BinOperator.process m["op"], le, re
            elsif m = @var.scan MULTIPLE_EXPR
              stack = [] of Expression | BoolOperator
              m.each do |match|
                stack << BoolOperator.new match["op"] if match["op"]?
                stack << Expression.new match["expr"]
              end
              BoolOperator.process stack, data
            else
              raise InvalidExpression.new "Invalid Expression : #{@var}"
            end

      if ret.is_a? Any
        ret
      else
        Any.new ret
      end
    end
  end
end
