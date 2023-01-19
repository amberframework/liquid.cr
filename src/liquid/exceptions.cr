module Liquid
  # Base class for all exceptions raised by Liquid.cr shard.
  class LiquidException < Exception
  end

  # Exception raised on syntax errors.
  class SyntaxError < LiquidException
    # Line number where the syntax error was found.
    property line_number : Int32 = -1
  end

  class InvalidStatement < LiquidException
  end

  # Exception used for any non-fatal errors that can happen while rendering a liquid template.
  class InvalidExpression < LiquidException
    def initialize(message : String)
      super("Liquid error: #{message}")
    end
  end

  # Error generated when a variable used in a template doesn't exists in the current context.
  #
  # This exception is never raised whatever the context error mode, to access it check `Context#errors`.
  class UndefinedVariable < InvalidExpression
    def initialize(var_name : String)
      super("Undefined variable: \"#{var_name}\".")
    end
  end

  # Error generated when a filter used in a template doesn't exists.
  #
  # This exception is only raised in `Context::ErrorMode::Strict` error mode.
  class UndefinedFilter < InvalidExpression
    def initialize(filter_name : String)
      super("Undefined filter: #{filter_name}")
    end
  end

  # Exception raised by filters if something went wrong.
  class FilterArgumentException < InvalidExpression
  end
end
