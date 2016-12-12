require "./tokens"

module Liquid
  class Lexer
    RAW = /^(?<raw>[^{]+)/
    STATEMENT = /\{%(?<full> ?(?<keyword>[a-z]+)([^%]*))%}/
    EXPRESSION = /\{{(?<expr>[^}]*)}}/

    @template : Array(Token)
    @str : String


    def initialize
      @template = Array(Token).new
      @str = ""
    end

    def consume(start : Nil)
    end

    def consume(start : Int32)
      @str = @str[start..-1]
    end

    def tokenize(@str : String)
      prev = nil
      while !@str.empty? && prev != @str
        prev = @str
        if match = @str.match(RAW)
          @template << Raw.new(match["raw"])
          consume(match.end)
        elsif match = @str.match(STATEMENT)
          @template << statement(match)
          consume(match.end)
        elsif match = @str.match(EXPRESSION)
          @template << expression(match)
          consume(match.end)
        end
      end
      @template
    end

    def expression(match)
      Expression.new match["expr"]
    end

    def statement(match)
      case match["keyword"]
      when "for" then ForStatement.new(match["full"])
      when "endfor" then EndForStatement.new
      when "if" then IfStatement.new match["full"]
      when "elsif" then ElsIfStatement.new match["full"]
      when "else" then ElseStatement.new
      when "endif" then EndIfStatement.new
      else
        Statement.new(match["full"])
      end
    end

  end
end
