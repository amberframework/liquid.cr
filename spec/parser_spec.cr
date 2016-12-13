require "./spec_helper"

include Liquid

describe Liquid::Parser do
  it "parses raw text" do
    txt = "raw text"
    template = Parser.parse txt
    expected = [Nodes::Raw.new(Tokens::Raw.new("raw text"))]
    template.root.children.should eq expected
  end

  it "parses for loop" do
    txt = "{% for x in 0..2 %} shown 2 times {% endfor %}"
    template = Liquid::Parser.parse txt

    expected = [] of Nodes::Node
    expected << Nodes::For.new(Tokens::ForStatement.new "")
    expected.last << Nodes::Raw.new(Tokens::Raw.new " shown 2 times ")

    template.root.children.should eq expected
  end

  it "parses if statement" do
    txt = "{% if a == true %} shown {% endif %}"
    template = Liquid::Parser.parse txt

    expected = [] of Nodes::Node
    expected << Nodes::If.new(Tokens::IfStatement.new "")
    expected.last << Nodes::Raw.new(Tokens::Raw.new " shown ")

    template.root.children.should eq expected
  end

  it "parses if else statement" do
    txt = "{% if a == true %} shown {% else %} not shown {% endif %}"
    template = Liquid::Parser.parse txt

    expected = [] of Nodes::Node
    if_node = Nodes::If.new(Tokens::IfStatement.new "")
    if_node << Nodes::Raw.new(Tokens::Raw.new " shown ")
    else_node = Nodes::Else.new(Tokens::ElseStatement.new)
    else_node << Nodes::Raw.new(Tokens::Raw.new " not shown ")
    if_node.set_else else_node
    expected << if_node

    template.root.children.should eq expected
  end
end
