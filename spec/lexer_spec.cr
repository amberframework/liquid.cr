require "./spec_helper"

include Liquid

describe Lexer do

  it "parses raw text" do
    lexer = Lexer.new
    result = lexer.parse "raw content"
    result.should eq(Template.new Raw.new("raw content"))
  end

  it "parses statement" do
    lexer = Lexer.new
    result = lexer.parse "{% for x in 0..2 %}{% endfor %}"

    template = Template.new
    template << ForStatement.new(" for x in 0..2 ")
    template << EndForStatement.new

    result.should eq( template )
  end

  it "parses statement with raw content" do
    lexer = Lexer.new
    result = lexer.parse "{% for x in 0..2 %}raw content{% endfor %}"

    template = Template.new
    template << ForStatement.new("for x in 0..2")
    template << Raw.new "raw content"
    template << EndForStatement.new

    result.should eq( template )
  end

  it "parses statement with raw content and newlines" do
    lexer = Lexer.new
    result = lexer.parse "{% for x in 0..2 %}
      raw content
    {% endfor %}"

    template = Template.new
    template << ForStatement.new("for x in 0..2")
    template << Raw.new "\n      raw content\n    "
    template << EndForStatement.new

    result.should eq( template )
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
    result = lexer.parse txt
    
    template = Template.new
    template << Raw.new "\n    "
    template << IfStatement.new("if kenny.sick")
    template << Raw.new "\n      Kenny is sick.\n    "
    template << ElsIfStatement.new("elif kenny.dead")
    template << Raw.new "\n      You killed Kenny!  You bastard!!!\n    "
    template << ElseStatement.new
    template << Raw.new "\n      Kenny looks okay --- so far\n    "
    template << EndIfStatement.new
    template << Raw.new "\n    "

    result.should eq( template )
  end

  it "parses expression" do
    lexer = Lexer.new
    result = lexer.parse "{{ toto }}"

    template = Template.new
    template << Expression.new("toto")

    result.should eq( template )
  end

end