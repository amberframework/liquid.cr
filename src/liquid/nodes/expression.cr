require "./node"

module Liquid::Nodes

  OPERATOR = /==|!=|<=|>=|<|>/
  
  GVAR = /[a-z]\w*(\.[a-z]\w*)*/
  VAR = /[a-z]\w*(?:\.[a-z]\w*)*/

  
  STRING = /"[^"]*"/
  INT    = /-?[1-9][0-9]*/
  FLOAT  = /#{INT}\.[0-9]+/
  TYPE    = /(?:#{STRING})|(?:#{INT})|(?:#{FLOAT})/
  TYPE_OR_VAR = /(?:#{TYPE})|(?:#{VAR})/
  
  CMP     = /(?:#{TYPE_OR_VAR}) ?(?:#{OPERATOR}) ?(?:#{TYPE_OR_VAR})/
  GCMP     = /(?<left>#{TYPE_OR_VAR}) ?(?<op>#{OPERATOR}) ?(?<right>#{TYPE_OR_VAR})/

  GSTRING = /^"(?<str>[^"]*)"$/
  GINT    = /(?<intval>#{INT})/
  GFLOAT  = /(?<floatval>#{FLOAT})/

  EXPR     = /\s*(?<left>#{VAR}) ?(?<op>#{OPERATOR}) ?(?<right>#{TYPE})\s*/

  MULTIPLE_EXPR = /(?: (?<op>or|and) )?(?<expr>#{CMP})/

  abstract class AbstractExpression < Node
  end


  class Comparison < AbstractExpression
    def initialize(@content)
    end

    def eval(data) : DataType
    end

    def render(data, io)
    end
  end

  class Boolean < AbstractExpression
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

    def render(data, io)
      @inner ? "true" : "false"
    end
  end   

  class Expression < AbstractExpression

    @var : String

    # Improve template rendering time by adding leaf node when possible
    # instead of evaluating at render time
    def initialize(token : Tokens::Expression)
      @var = token.content.strip
      @children << Boolean.new @var if @var == "true" || @var == "false"
      if m = @var.match GSTRING
        @children << Raw.new m["str"]
      end
    end

    def initialize(var)
      @var = var.strip
    end

    private def intern(re)
      /^#{re}$/
    end

    def eval(data) : Context::DataType
      if @var == "true" || @var == "false"
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
        op = BinOperator.new m["op"]
        le = Expression.new m["left"]
        re = Expression.new m["right"]
        op.call le.eval(data), re.eval(data)
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
    end

    def render(data, io)
      io << eval(data) if @children.empty?
      @children.each &.render(data, io)
    end
  end
end
