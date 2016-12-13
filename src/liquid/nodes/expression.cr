require "./node"

module Liquid::Nodes
  class Expression < Node
    OPERATOR = /==|!=|<=|>=|<|>/
    EXPR     = /^\s*(?<left>#{VAR}) ?(?<op>#{OPERATOR}) ?(?<right>#{VAR})\s*$/

    STRING = /^\s*"(?<str>[^"]*)"\s*$/
    INT    = /\s*(?<intval>[1-9][0-9]*)\s*/
    FLOAT  = /\s*(?<floatval>#{INT}\.[0-9]+)\s*/

    @var : String

    def initialize(token : Tokens::Expression)
      @var = token.content.strip
    end

    def initialize(var)
      @var = var.strip
    end

    def eval(data) : Context::DataType
      if @var == "true"
        true
      elsif @var == "false"
        false
      elsif m = @var.match STRING
        m["str"]
      elsif m = @var.match /^#{INT}$/
        m["intval"].to_i
      elsif m = @var.match /^#{FLOAT}$/
        m["floatval"].to_f32
      elsif @var.match /^#{VAR}$/
        data.get(@var)
      elsif m = @var.match EXPR
        op = BinOperator.new m["op"]
        le = Expression.new m["left"]
        re = Expression.new m["right"]
        op.call le.eval(data), re.eval(data)
      else
        raise InvalidExpression.new "Invalid Expression : #{@var}"
      end
    end

    def render(data, io)
      io << eval(data)
    end
  end
end
