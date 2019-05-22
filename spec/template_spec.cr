require "./spec_helper"

include Liquid

describe Template do
  it "should render raw text" do
    tpl = Parser.parse("raw text")
    template_path = __DIR__
    tpl.template_path = template_path

    tpl.render(Context.new).should eq "raw text"
    tpl.template_path.should eq template_path
  end

  it "shouldn't render comments" do
    tpl = Parser.parse("PRE{% comment %} raw {% assign mavar = 15 %} text {% endcomment %}POST")
    tpl.render(Context.new).should eq "PREPOST"
  end

  it "should render from file" do
    filename = "spec/data/include.html"
    file_path = File.dirname(filename)

    tpl = Parser.parse(File.open(filename))
    tpl.render(Context.new).should eq File.read(filename)
    tpl.template_path.should eq file_path
  end

  it "should render for loop with range" do
    tpl = Parser.parse("{% for x in 0..2 %}something {% endfor %}")
    tpl.render(Context.new).should eq "something something something "
  end

  it "should render for loop with iter variable" do
    tpl = Parser.parse("{% for x in 0..2 %}{{ x }}{% endfor %}")
    tpl.render(Context.new).should eq "012"
  end

  it "should render for loop with loop variable" do
    tpl = Parser.parse("{% for x in 0..2 %}
    Iteration n°{{ loop.index }}
    {% endfor %}")
    tpl.render(Context.new).should eq "\n    Iteration n°1\n    \n    Iteration n°2\n    \n    Iteration n°3\n    "
  end

  it "should render for loop when iterating over an array" do
    tpl = Parser.parse("{% for x in myarray %}
    Got : {{x}}
    {% endfor %}")
    ctx = Context.new
    ctx.set("myarray", [1, 12.2, "here"])
    tpl.render(ctx).should eq "\n    Got : 1\n    \n    Got : 12.2\n    \n    Got : here\n    "
  end

  it "should render for loop when iterating over a hash by value (key+value array)" do
    tpl = Parser.parse <<-EOT
    {%- for v in myhash -%}
      Got : {{v[0]}} => {{v[1]}}
    {%- endfor -%}
    EOT

    ctx = Context.new
    ctx.set("myhash", {"key1" => 1, "key2" => "val2", "key3" => ["val3a", "val3b"]})
    tpl.render(ctx).should eq %(Got : key1 => 1Got : key2 => val2Got : key3 => [\"val3a\", \"val3b\"])
  end

  # it "should render for loop when iterating over a hash by key, value" do
  #   tpl = Parser.parse <<-EOT
  #   {%- for k, v in myhash -%}
  #     Got : {{k}} => {{v}}
  #   {%- endfor -%}
  #   EOT

  #   ctx = Context.new
  #   ctx.set("myhash", {"key1" => 1, "key2" => "val2", "key3" => ["val3a", "val3b"]})
  #   tpl.render(ctx).should eq %(Got : key1 => 1Got : key2 => val2Got : key3 => [\"val3a\", \"val3b\"])
  # end

  it "should render if statement" do
    tpl = Parser.parse("{% if var == true %}true{% endif %}")
    ctx = Context.new
    ctx.set("var", true)
    tpl.render(ctx).should eq "true"
    ctx.set("var", false)
    tpl.render(ctx).should eq ""
  end

  it "should render if statement with multiple operation" do
    tpl = Parser.parse("{% if var == true and another == \"dat string\" %}true{% endif %}")
    ctx = Context.new
    ctx.set("var", true)
    ctx.set "another", "dat string"
    tpl.render(ctx).should eq "true"
    ctx.set("another", "something")
    tpl.render(ctx).should eq ""
  end

  it "should render if statement with zero comparison" do
    tpl = Parser.parse("{% if var > 0 %}true{% endif %}")
    ctx = Context.new
    ctx.set("var", 1)
    tpl.render(ctx).should eq "true"
    ctx.set("var", 0)
    tpl.render(ctx).should eq ""
  end

  it "should render if else statement" do
    tpl = Parser.parse("{% if true and var == true %}true{% else %}false{% endif %}")
    ctx = Context.new
    ctx.set("var", true)
    tpl.render(ctx).should eq "true"
    ctx.set("var", false)
    tpl.render(ctx).should eq "false"
  end

  it "should render if elsif else statement" do
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
    ctx.set "kenny.state", "dead"

    tpl = Parser.parse txt
    result = tpl.render ctx
    result.should eq "\n    \n      You killed Kenny!  You bastard!!!\n    \n    "
  end

  it "should render if elsif else statement - variant 2" do
    txt = <<-EOT
    {%- if kenny.state == \"sick\" -%}
      Kenny is sick.
    {%- elsif kenny.state == 'dead' -%}
      You killed Kenny!  You bastard!!!
    {%- else -%}
      Kenny looks okay --- so far
    {%- endif -%}
    EOT

    ctx = Context.new
    ctx.set "kenny.state", "dead"

    tpl = Parser.parse txt
    result = tpl.render ctx
    result.should eq "You killed Kenny!  You bastard!!!"
  end

  it "should render if statement - variant 3" do
    txt = <<-EOT
    {%- if mykey? -%}
      Key present
    {%- else -%}
      Key absent
    {%- endif -%}
    {%- if !mykey? -%}
      Key absent
    {%- else -%}
      Key present
    {%- endif -%}
    EOT

    ctx = Context.new(strict: true)

    tpl = Parser.parse txt
    result = tpl.render ctx
    result.should eq "Key absentKey absent"

    ctx["mykey"] = true
    result = tpl.render ctx
    result.should eq "Key presentKey present"
  end

  it "should render captured variables" do
    tpl = Template.parse "{% capture mavar %}Hello World!{% endcapture %}{{mavar}}"
    tpl.render(Context.new).should eq "Hello World!"
  end

  it "should handle increment block" do
    tpl = Template.parse "{% increment mavar %}"
    ctx = Context.new
    tpl.render ctx
    ctx.get("mavar").should eq 1
    tpl.render ctx
    ctx.get("mavar").should eq 2
  end

  it "should handle decrement block" do
    tpl = Template.parse "{% decrement mavar %}"
    ctx = Context.new
    tpl.render ctx
    ctx.get("mavar").should eq -1
    tpl.render ctx
    ctx.get("mavar").should eq -2
  end

  it "should render assigned variable" do
    tpl = Parser.parse "{% assign var = \"Hello World\"%}{{var}}"
    tpl.render(Context.new).should eq "Hello World"

    tpl = Parser.parse "{% assign var = 12.5%}{{var}}"
    tpl.render(Context.new).should eq "12.5"
  end

  it "should render abs filters" do
    tpl = Parser.parse "{{var | abs }}"
    ctx = Context.new
    ctx.set "var", -12
    tpl.render(ctx).should eq "12"
  end

  it "should render append filter" do
    tpl = Parser.parse "{{var | append: \" World\" }}"
    ctx = Context.new
    ctx.set "var", "Hello"
    tpl.render(ctx).should eq "Hello World"
  end

  it "should render replace filter" do
    tpl = Template.parse %({{var | replace: "a", "b"}})
    ctx = Context{"var" => "aaa"}
    tpl.render(ctx).should eq "bbb"
  end

  it "should render replace filter 2" do
    tpl = Template.parse %({{var | replace: "a,b", "b,c"}})
    ctx = Context{"var" => "a,b a,b a,b"}
    tpl.render(ctx).should eq "b,c b,c b,c"
  end

  it "should support array access via literal" do
    tpl = Template.parse %({{ objects[1] }}, {{ objects[0] }}, {{ objects[-1] }}, {{ objects[2] }})
    ctx = Context{"objects" => ["first", "second", "third"]}
    tpl.render(ctx).should eq "second, first, third, third"
  end

  it "should support array access via variable" do
    tpl = Template.parse %({% assign idx = 2 %}{% assign idx2 = -2 %}{{ objects[idx] }}, {{ objects[idx2] }}, {{ objects[obj.id] }})
    ctx = Context{"objects" => ["first", "second", "third"], "obj" => Hash{"id" => 1}}
    tpl.render(ctx).should eq "third, second, second"
  end

  it "should support Array#size" do
    tpl = Template.parse %({{ objects.size }})
    ctx = Context{"objects" => ["first", "second", "third"]}
    tpl.render(ctx).should eq "3"
  end

  it "should support Hash#size" do
    tpl = Template.parse %({{ objects.size }})
    ctx = Context{"objects" => {"first" => "1st", "second" => "2nd", "third" => "3rd"}}
    tpl.render(ctx).should eq "3"
  end

  it "should support String#size" do
    tpl = Template.parse %({{ str.size }})
    ctx = Context{"str" => "12345678"}
    tpl.render(ctx).should eq "8"
  end

  it "should pre-initialize context with special `empty` array" do
    tpl = Template.parse %({% if array == empty %}empty{% endif %})
    ctx = Context.new
    tpl.render(ctx).should eq "" # here array is nil, not empty
    ctx["array"] = [] of String
    tpl.render(ctx).should eq "empty"
    ctx["array"] = ["val1"]
    tpl.render(ctx).should eq ""
  end

  it "should support #blank?" do
    tpl = Template.parse %({% if var.blank? %}blank{% endif %})
    ctx = Context{"var" => "12345678"}
    tpl.render(ctx).should eq ""
    ctx = Context{"var" => ""}
    tpl.render(ctx).should eq "blank"
    ctx = Context{"var" => [] of String}
    tpl.render(ctx).should eq "blank"
    ctx = Context{"var" => ["val1"]}
    tpl.render(ctx).should eq ""
    ctx = Context{"var" => {} of String => String}
    tpl.render(ctx).should eq "blank"
    ctx = Context{"var" => {"key1" => "val1"}}
    tpl.render(ctx).should eq ""
    ctx = Context{"notvar" => ""}
    tpl.render(ctx).should eq "blank"
  end

  it "should support #present?" do
    tpl = Template.parse %({% if var.present? %}present{% endif %})
    ctx = Context{"var" => "12345678"}
    tpl.render(ctx).should eq "present"
    ctx = Context{"var" => [] of String}
    tpl.render(ctx).should eq ""
    ctx = Context{"var" => ["val1"]}
    tpl.render(ctx).should eq "present"
    ctx = Context{"var" => {} of String => String}
    tpl.render(ctx).should eq ""
    ctx = Context{"var" => {"key1" => "val1"}}
    tpl.render(ctx).should eq "present"
    ctx = Context{"var" => ""}
    tpl.render(ctx).should eq ""
    ctx = Context{"notvar" => ""}
    tpl.render(ctx).should eq ""
  end

  it "should support contains for String, Array values" do
    tpl = Template.parse %({% if var contains 'asdf' %}yep{% else %}nope{% endif %})
    ctx = Context{"var" => "123"}
    tpl.render(ctx).should eq "nope"
    ctx = Context{"var" => "123asdffdsa321"}
    tpl.render(ctx).should eq "yep"
    ctx = Context{"var" => [] of String}
    tpl.render(ctx).should eq "nope"
    ctx = Context{"var" => ["asdf"]}
    tpl.render(ctx).should eq "yep"
    ctx = Context{"var" => {} of String => String}
    tpl.render(ctx).should eq "nope"
    # ctx = Context{"var" => {"asdf" => "val1"}}
    # tpl.render(ctx).should eq "yep"
  end

  it "should support combinations of array/hash access and property access" do
    tpl = Template.parse %({% assign myvar = objects[1][1] %}{{ objects.size }} {{ objects[1].size }} {{ objects[1][1] }} {{ hash['first'] }} {{ hash[first] }} {{ hash[objects[0]] }})
    ctx = Context{"first" => "first", "objects" => ["first", ["second-a", "second-b"], "third"], "hash" => {"first" => "val"}}
    tpl.render(ctx).should eq "3 2 second-b val val val"
    ctx.get("myvar").should eq "second-b"
  end

  it "should respect strict mode on Context" do
    ctx = Context.new
    tpl = Template.parse %({{ missing }}{{ obj.missing }})
    tpl.render(ctx).should eq ""

    ctx.strict = true
    expect_raises(KeyError) { tpl.render(ctx) }

    ctx["missing"] = "present"
    ctx["obj"] = {something: "something"} # still didn't define "missing"
    expect_raises(KeyError) { tpl.render(ctx) }

    ctx["missing"] = "present"
    ctx["obj"] = {something: "something", missing: "present"}
    tpl.render(ctx).should eq "presentpresent"
  end

  it "filter should receive all args, in order" do
    ctx = Context.new
    tpl = Template.parse %({{ "" | arg_test: '1', "2", 3, 4.0, [5] }})
    tpl.render(ctx).should eq "1, 2, 3, 4.0, [5]"
  end
end
