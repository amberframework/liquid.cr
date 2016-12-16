require "./spec_helper"

include Liquid

describe Liquid::Parser do
  it "parses raw text" do
    txt = "raw text"
    template = Parser.parse txt
    expected = [Block::Raw.new("raw text")]
    template.root.children.should eq expected
  end

  it "parses for loop" do
    txt = "{% for x in 0..2 %} shown 2 times {% endfor %}"
    template = Liquid::Parser.parse txt

    expected = [] of Block::Node
    expected << Block::For.new("for x in 0..2")
    expected.last << Block::Raw.new(" shown 2 times ")

    template.root.children.should eq expected
  end

  it "parses if statement" do
    txt = "{% if a == true %} shown {% endif %}"
    template = Liquid::Parser.parse txt

    expected = [] of Block::Node
    expected << Block::If.new("if a == true")
    expected.last << Block::Raw.new(" shown ")

    template.root.children.should eq expected
  end

  it "parses if else statement" do
    txt = "{% if a == true %} shown {% else %} not shown {% endif %}"
    template = Liquid::Parser.parse txt

    expected = [] of Block::Node
    if_node = Block::If.new("if a == true")
    if_node << Block::Raw.new(" shown ")
    else_node = Block::Else.new("")
    else_node << Block::Raw.new(" not shown ")
    if_node << else_node
    expected << if_node

    template.root.children.should eq expected
  end
end
