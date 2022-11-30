module Liquid
  struct Token
    enum Kind
      Raw
      Expression
      Statement
    end

    getter value : String
    getter raw_value : String
    getter line_number : Int32
    getter kind : Kind
    getter? lstrip : Bool
    getter? rstrip : Bool

    def initialize(@raw_value : String, @line_number)
      if @raw_value.starts_with?("{{")
        @kind = Kind::Expression
        @lstrip = should_lstrip?
        @rstrip = should_rstrip?
        @value = strip_markup(@raw_value)
      elsif @raw_value.starts_with?("{%")
        @kind = Kind::Statement
        @lstrip = should_lstrip?
        @rstrip = should_rstrip?
        @value = strip_markup(@raw_value)
      else
        @kind = Kind::Raw
        @lstrip = false
        @rstrip = false
        @value = @raw_value
      end
    end

    private def should_lstrip?
      @raw_value[2] == '-'
    end

    private def should_rstrip?
      @raw_value[-3] == '-'
    end

    private def strip_markup(value : String)
      i = @lstrip ? 3 : 2
      j = @rstrip ? -3 : -2
      value[i...j]
    end
  end
end
