# exceptions.cr

module Liquid
  class LiquidException < Exception
  end

  class SyntaxError < LiquidException
    property line_number : Int32 = -1
  end

  class InvalidExpression < LiquidException
  end

  class InvalidStatement < LiquidException
  end

  class FilterArgumentException < LiquidException
  end
end
