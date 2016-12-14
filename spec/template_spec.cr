require "./spec_helper"

include Liquid

describe Template do
  it "render raw text" do
    tpl = Parser.parse("raw text")
    tpl.render(Context.new).should eq "raw text"
  end

  it "render for loop with range" do
    tpl = Parser.parse("{% for x in 0..2 %}something {% endfor %}")
    tpl.render(Context.new).should eq "something something something "
  end

  it "render for loop with iter variable" do
    tpl = Parser.parse("{% for x in 0..2 %}{{ x }}{% endfor %}")
    tpl.render(Context.new).should eq "012"
  end

  it "render for loop with loop variable" do
    tpl = Parser.parse("{% for x in 0..2 %}
    Iteration n°{{ loop.index }}
    {% endfor %}")
    tpl.render(Context.new).should eq "\n    Iteration n°1\n    \n    Iteration n°2\n    \n    Iteration n°3\n    "
  end

  it "render for loop when iterating over an array" do
    tpl = Parser.parse("{% for x in myarray %}
    Got : {{x}}
    {% endfor %}")
    ctx = Context.new
    ctx.set("myarray", [1, 12.2, "here"])
    tpl.render(ctx).should eq "\n    Got : 1\n    \n    Got : 12.2\n    \n    Got : here\n    "
  end

  it "render if statement" do
    tpl = Parser.parse("{% if var == true %}true{% endif %}")
    ctx = Context.new
    ctx.set("var", true)
    tpl.render(ctx).should eq "true"
    ctx.set("var", false)
    tpl.render(ctx).should eq ""
  end
  
  it "render if statement with multiple operation" do
    tpl = Parser.parse("{% if var == true and another == \"dat string\" %}true{% endif %}")
    ctx = Context.new
    ctx.set("var", true)
    ctx.set "another", "dat string"
    tpl.render(ctx).should eq "true"
    ctx.set("another", "something")
    tpl.render(ctx).should eq ""
  end

  it "render if else statement" do
    tpl = Parser.parse("{% if var == true %}true{% else %}false{% endif %}")
    ctx = Context.new
    ctx.set("var", true)
    tpl.render(ctx).should eq "true"
    ctx.set("var", false)
    tpl.render(ctx).should eq "false"
  end

  it "render if elsif else statement" do
    txt = "
    {% if kenny.sick %}
      Kenny is sick.
    {% elsif kenny.dead %}
      You killed Kenny!  You bastard!!!
    {% else %}
      Kenny looks okay --- so far
    {% endif %}
    "
    ctx = Context.new
    ctx.set "kenny.sick", false
    ctx.set "kenny.dead", true

    tpl = Parser.parse txt
    result = tpl.render ctx
    result.should eq "\n    \n      You killed Kenny!  You bastard!!!\n    \n    "
  end

  it "render assigned variable" do
    tpl = Parser.parse "{% assign var = \"Hello World\"%}{{var}}"
    tpl.render(Context.new).should eq "Hello World"

    tpl = Parser.parse "{% assign var = 12.5%}{{var}}"
    tpl.render(Context.new).should eq "12.5"
  end
end
