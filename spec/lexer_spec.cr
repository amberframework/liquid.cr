require "./spec_helper"

include Liquid

describe Lexer do

  it "parses raw text" do
    lexer = Lexer.new
    result = lexer.tokenize "raw content"
    tokens = Array(Token).new
    tokens << Raw.new("raw content")
    result.should eq(tokens)
  end

  it "parses statement" do
    lexer = Lexer.new
    result = lexer.tokenize "{% for x in 0..2 %}{% endfor %}"

    tokens = Array(Token).new
    tokens << ForStatement.new(" for x in 0..2 ")
    tokens << EndForStatement.new

    result.should eq( tokens )
  end

  it "parses statement with raw content" do
    lexer = Lexer.new
    result = lexer.tokenize "{% for x in 0..2 %}raw content{% endfor %}"

    tokens = Array(Token).new
    tokens << ForStatement.new("for x in 0..2")
    tokens << Raw.new "raw content"
    tokens << EndForStatement.new

    result.should eq( tokens )
  end

  it "parses statement with raw content and newlines" do
    lexer = Lexer.new
    result = lexer.tokenize "{% for x in 0..2 %}
      raw content
    {% endfor %}"

    tokens = Array(Token).new
    tokens << ForStatement.new("for x in 0..2")
    tokens << Raw.new "\n      raw content\n    "
    tokens << EndForStatement.new

    result.should eq( tokens )
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
    
    tokens = Array(Token).new
    tokens << Raw.new "\n    "
    tokens << IfStatement.new("if kenny.sick")
    tokens << Raw.new "\n      Kenny is sick.\n    "
    tokens << ElsIfStatement.new("elif kenny.dead")
    tokens << Raw.new "\n      You killed Kenny!  You bastard!!!\n    "
    tokens << ElseStatement.new
    tokens << Raw.new "\n      Kenny looks okay --- so far\n    "
    tokens << EndIfStatement.new
    tokens << Raw.new "\n    "

    result.should eq( tokens )
  end

  it "parses expression" do
    lexer = Lexer.new
    result = lexer.tokenize "{{ toto }}"

    tokens = Array(Token).new
    tokens << Expression.new("toto")

    result.should eq( tokens )
  end

end