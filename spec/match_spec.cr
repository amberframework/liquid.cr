require "./spec_helper"

describe Template do
  it "should match raw data" do
    tpl = Parser.parse("raw text")

    tpl.matches?("raw text").should eq true
    tpl.matches?("Raw text").should eq false
  end

  it "should match statement with a comment" do
    tpl = Parser.parse("PRE{% comment %} raw {% assign mavar = 15 %} text {% endcomment %}POST")

    tpl.matches?("PREPOST").should eq true
  end

  it "should match if statement" do
    tpl = Parser.parse("{% if var == true %}true{% endif %}")

    tpl.matches?("true").should eq true
    tpl.matches?("").should eq true
    tpl.matches?("false").should eq false
  end

  it "should match unless statement", tags: "current" do
    tpl = Parser.parse("{% unless var == true %}false{% endif %}")

    tpl.matches?("false").should eq true
    tpl.matches?("").should eq true
    tpl.matches?("true").should eq false
  end

  it "should match if elsif else statement" do
    tpl = Parser.parse "
    {% if kenny.sick %}
      Kenny is sick.
    {% elsif kenny.dead %}
      You killed Kenny!  You bastard!!!
    {% else %}
      Kenny looks okay --- so far
    {% endif %}
    "

    tpl.matches?("\n    \n      Kenny is sick.\n    \n    ").should eq true
    tpl.matches?("\n    \n      You killed Kenny!  You bastard!!!\n    \n    ").should eq true
    tpl.matches?("\n    \n      Kenny looks okay --- so far\n    \n    ").should eq true
  end

  it "should match case statement without an else option" do
    tpl = Parser.parse("We are {% case var %}{% when \"here\" %}here{% when \"there\" %}there{% endcase %}")

    tpl.matches?("We are here").should eq true
    tpl.matches?("We are there").should eq true
    tpl.matches?("We are ").should eq true
  end

  it "should match case statement with an else option" do
    tpl = Parser.parse("{% case var %}{% when \"here\" %}We are here{% else %}We are somewhere{% endcase %}")

    tpl.matches?("We are here").should eq true
    tpl.matches?("We are somewhere").should eq true
    tpl.matches?("We are anywhere").should eq false
  end

  it "should match for loop with range" do
    tpl = Parser.parse("{% for x in 0..2 %}something {% endfor %}")

    tpl.matches?("something something something ").should eq true
    tpl.matches?("somethingsomethingsomething ").should eq false
  end

  it "should match for loop with loop variable" do
    tpl = Parser.parse("{% for x in 0..2 %}
    Iteration n°{{ forloop.index }}
    {% endfor %}")

    tpl.matches?("\n    Iteration n°1\n    \n    Iteration n°2\n    \n    Iteration n°3\n    ").should eq true
  end

  it "should match assigned variable with filters" do
    tpl = Parser.parse "{%   assign var  =  \"abc\" | upcase%}{{var}}"

    tpl.matches?("ABC").should eq true
  end

  it "should match a nested for loop" do
    tpl = Parser.parse("{% for x in 0..2 %}{% if x | modulo: 2 == 0 %}even{% else %}odd{% endif %} {% endfor %}")

    tpl.matches?("even odd even ").should eq true
    tpl.matches?("even noteven even").should eq false
  end
end
