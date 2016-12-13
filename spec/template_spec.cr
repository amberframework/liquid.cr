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

  it "render if statement" do
    tpl = Parser.parse("{% if var == true %}true{% endif %}")
    ctx = Context.new
    ctx.set("var", true)
    tpl.render(ctx).should eq "true"
    ctx.set("var", false)
    tpl.render(ctx).should eq ""
  end
end
