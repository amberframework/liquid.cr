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

    def initialize(content : String)
      @raw = content
      if match = content.match GFILTERED
        @first = Expression.new match["first"]
        @filters = Array(Tuple(Filters::Filter, Array(Expression)?)).new
      else
        raise InvalidExpression.new "Invalid filter use :#{content}"
      end
    end
  end

  class Boolean < AbstractExpression
    getter inner
    @inner : Bool

    def initialize(content : String)
      if match(content)
        @inner = content == "true"
      else
        raise Exception.new "Invalid Boolean expression : #{content}"
      end
    end

    def match(str : String) : Regex::MatchData?
      str.match /^false$|^true$/
    end
  end

  class Expression < AbstractExpression
    getter var
    @var : String

    def initialize(content : String)
      @var = content.strip
      pre_cache
    end

    def pre_cache
      @children << Boolean.new @var if @var == "true" || @var == "false"
      if m = @var.match GSTRING
        @children << Block::Raw.new m["str"]
      end
      if @var.match INTERNED_GFILTERED
        @children << Filtered.new @var
      end
    end

    INTERNED_GSTRING     = /^#{GSTRING}$/
    INTERNED_GINT        = /^#{GINT}$/
    INTERNED_GFLOAT      = /^#{GFLOAT}$/
    INTERNED_ARRAY       = /^#{ARRAY}$/
    INTERNED_VAR         = /^#{VAR}$/
    INTERNED_GCMP        = /^#{GCMP}$/
    INTERNED_GFILTERED   = /^#{GFILTERED}$/
    PARENTHESIZED_SCALAR = /^(#{SCALAR})/

    def eval(data : Context) : Any
      ret = if @var == "true" || @var == "!false"
              true
            elsif @var == "false" || @var == "!true"
              false
            elsif @var == "nil"
              nil
            elsif m = @var.match INTERNED_GSTRING
              m["str"]
            elsif m = @var.match INTERNED_GINT
              m["intval"].to_i
            elsif m = @var.match INTERNED_GFLOAT
              m["floatval"].to_f32
            elsif m = @var.match INTERNED_ARRAY # scalars only for now; no variables allowed
              str = $1
              scalars = Array(Expression).new
              while str =~ PARENTHESIZED_SCALAR
                match = $1
                scalars << Expression.new(match)
                str = str.sub(match, "")
                str = str.sub(/^\s*,\s*/, "")
              end
              scalars.map { |s| s.eval(data) }
            elsif m = @var.match INTERNED_VAR
              data.get(@var) # Context handles . and [] access
            elsif m = @var.match INTERNED_GCMP
              le = Expression.new(m["left"]).eval data
              re = Expression.new(m["right"]).eval data
              BinOperator.process m["op"], le, re
            elsif m = @var.scan MULTIPLE_EXPR
              stack = [] of Expression | BoolOperator
              m.each do |match|
                stack << BoolOperator.new match["boolop"] if match["boolop"]?
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
