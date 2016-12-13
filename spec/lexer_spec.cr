require "./spec_helper"

include Liquid

describe Lexer do
  it "parses raw text" do
    lexer = Lexer.new
    result = lexer.tokenize "raw content"
    tokens = Array(Tokens::Token).new
    tokens << Tokens::Raw.new("raw content")
    result.should eq(tokens)
  end

  it "parses statement" do
    lexer = Lexer.new
    result = lexer.tokenize "{% for x in 0..2 %}{% endfor %}"

    tokens = Array(Tokens::Token).new
    tokens << Tokens::ForStatement.new(" for x in 0..2 ")
    tokens << Tokens::EndForStatement.new

    result.should eq(tokens)
  end

  it "parses statement with expression inside" do
    lexer = Lexer.new
    result = lexer.tokenize "{% for x in 0..2 %}{{x}}{% endfor %}"

    tokens = Array(Tokens::Token).new
    tokens << Tokens::ForStatement.new(" for x in 0..2 ")
    tokens << Tokens::Expression.new "x"
    tokens << Tokens::EndForStatement.new

    result.should eq(tokens)
  end

  it "parses statement with raw content" do
    lexer = Lexer.new
    result = lexer.tokenize "{% for x in 0..2 %}raw content{% endfor %}"

    tokens = Array(Tokens::Token).new
    tokens << Tokens::ForStatement.new("for x in 0..2")
    tokens << Tokens::Raw.new "raw content"
    tokens << Tokens::EndForStatement.new

    result.should eq(tokens)
  end

  it "parses statement with raw content and newlines" do
    lexer = Lexer.new
    result = lexer.tokenize "{% for x in 0..2 %}
      raw content
    {% endfor %}"

    tokens = Array(Tokens::Token).new
    tokens << Tokens::ForStatement.new("for x in 0..2")
    tokens << Tokens::Raw.new "\n      raw content\n    "
    tokens << Tokens::EndForStatement.new

    result.should eq(tokens)
  end

  it "parses if statement" do
    txt = "
    {% if kenny.sick %}
      Kenny is sick.
    {% elif kenny.dead %}
      You killed Kenny!  You bastard!!!
    {% else %}
      Kenny looks okay --- so far
    {% endif %}
    "
    lexer = Lexer.new
    result = lexer.tokenize txt
    tokens = Array(Tokens::Token).new
    tokens << Tokens::Raw.new "\n    "
    tokens << Tokens::IfStatement.new("if kenny.sick")
    tokens << Tokens::Raw.new "\n      Kenny is sick.\n    "
    tokens << Tokens::ElsIfStatement.new("elif kenny.dead")
    tokens << Tokens::Raw.new "\n      You killed Kenny!  You bastard!!!\n    "
    tokens << Tokens::ElseStatement.new
    tokens << Tokens::Raw.new "\n      Kenny looks okay --- so far\n    "
    tokens << Tokens::EndIfStatement.new
    tokens << Tokens::Raw.new "\n    "

    result.should eq(tokens)
  end

  it "parses expression" do
    lexer = Lexer.new
    result = lexer.tokenize "{{ toto }}"

    tokens = Array(Tokens::Token).new
    tokens << Tokens::Expression.new("toto")

    result.should eq(tokens)
  end
end
