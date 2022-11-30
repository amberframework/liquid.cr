require "./block"

module Liquid::Block
  class Raw < RawBlock
    getter content

    @content : String

    def initialize(@content)
    end

    def rstrip=(value : Bool)
      raise InvalidStatement.new("Raw tags can not have whitespace controls.") if value
    end

    def lstrip=(value : Bool)
      raise InvalidStatement.new("Raw tags can not have whitespace controls.") if value
    end

    def lstrip!
      @content = @content.lstrip
    end

    def rstrip!
      @content = @content.rstrip
    end

    def_equals @children, @content
  end
end
