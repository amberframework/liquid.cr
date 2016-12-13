require "./tokens"

include Liquid

module Liquid
  class Lexer
    RAW        = /^(?<raw>[^{]+)/
    STATEMENT  = /^\{%(?<full> ?(?<keyword>[a-z]+)([^%]*))%}/
    EXPRESSION = /^\{{(?<expr>[^}]*)}}/

    @template : Array(Tokens::Token)
    @str : String

    def initialize
      @template = Array(Tokens::Token).new
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
          @template << Tokens::Raw.new(match["raw"])
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
      Tokens::Expression.new match["expr"]
    end

    def statement(match)
      case match["keyword"]
      when "for"    then Tokens::ForStatement.new(match["full"])
      when "endfor" then Tokens::EndForStatement.new
      when "if"     then Tokens::IfStatement.new match["full"]
      when "elsif"  then Tokens::ElsIfStatement.new match["full"]
      when "else"   then Tokens::ElseStatement.new
      when "endif"  then Tokens::EndIfStatement.new
      else
        raise "Invalid statement : #{match}"
      end
    end
  end
end
