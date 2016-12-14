require "./node"

module Liquid::Nodes
  class Expression < Node
    OPERATOR = /==|!=|<=|>=|<|>/

    STRING = /^\s*"(?<str>[^"]*)"\s*$/
    INT    = /\s*(?<intval>[1-9][0-9]*)\s*/
    FLOAT  = /\s*(?<floatval>#{INT}\.[0-9]+)\s*/

    USTRING = /"[^"]*"/
    UINT    = /[1-9][0-9]*/
    UFLOAT  = /#{UINT}\.[0-9]+/
    TYPE    = /(?:#{USTRING})|(?:#{UINT})|(?:#{UFLOAT})|(?:#{UVAR})/
    
    EXPR     = /\s*(?<left>#{VAR}) ?(?<op>#{OPERATOR}) ?(?<right>#{TYPE})\s*/
    
    UEXPR     = /(?:#{UVAR}) ?(?:#{OPERATOR}) ?(?:#{TYPE})/

    MULTIPLE_EXPR = /(?: (?<op>or|and) )?(?<expr>#{UEXPR})/

    @var : String

    def initialize(token : Tokens::Expression)
      @var = token.content.strip
    end

    def initialize(var)
      @var = var.strip
    end

    private def intern(re)
      /^#{re}$/
    end

    def eval(data) : Context::DataType
      if @var == "true"
        true
      elsif @var == "false"
        false
      elsif m = @var.match STRING
        m["str"]
      elsif m = @var.match intern(INT)
        m["intval"].to_i
      elsif m = @var.match intern(FLOAT)
        m["floatval"].to_f32
      elsif @var.match intern(VAR)
        data.get(@var)
      elsif m = @var.match intern(EXPR)
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
      io << eval(data)
    end
  end
end
