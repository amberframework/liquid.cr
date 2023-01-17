require "./spec_helper"

private CTX = Context{"foo" => Liquid::Any{"a", "b"}}

describe "for tag" do
  it_renders("{% for e in foo %}{{ e }};{% endfor %}", "a;b;", CTX)
  it_renders("{% for i in (3..5) %}{{ i }}{% endfor %}", "345")
  it_renders("{% for e in foo %}{{ forloop.first }};{% endfor %}", "true;false;", CTX)
  it_renders("{% for e in foo %}{{ forloop.index }};{% endfor %}", "1;2;", CTX)
  it_renders("{% for e in foo %}{{ forloop.index0 }};{% endfor %}", "0;1;", CTX)
  it_renders("{% for e in foo %}{{ forloop.last }};{% endfor %}", "false;true;", CTX)
  it_renders("{% for e in foo %}{{ forloop.length }};{% endfor %}", "2;2;", CTX)
  it_renders("{% for e in foo %}{{ forloop.rindex }};{% endfor %}", "2;1;", CTX)
  it_renders("{% for e in foo %}{{ forloop.rindex0 }};{% endfor %}", "1;0;", CTX)
  it_renders("{% for e in foo %}{{ forloop.index }};({% for e in foo %}{{ forloop.parentloop.index }}{{ forloop.index }};{% endfor %}){% endfor %}", "1;(1;2;)2;(1;2;)", CTX)

  # TODO: for loop parameters
end
