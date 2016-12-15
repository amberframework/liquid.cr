# exceptions.cr

module Liquid
  class LiquidException < Exception
  end

  class InvalidExpression < LiquidException
  end

  class InvalidNode < LiquidException
  end

  class InvalidStatement < LiquidException
  end

  class FilterArgumentException < LiquidException
  end
end
