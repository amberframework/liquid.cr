require "./spec_helper"

private class TextDrop < Drop
  def array
    Any{"text0", "text1"}
  end

  def text
    "text from drop"
  end

  private def private_method
    "bad"
  end

  private def protected_method
    "bad"
  end

  def method_with_arg(arg)
    "bad"
  end
end

private class ProductDrop < Drop
  def texts
    TextDrop.new
  end
end

private class SuperTextDrop < TextDrop
  def super_text
    "super_text"
  end
end

private def compile(expr : String) : String
  StackMachine.new(expr).tap(&.compile).to_s
end

private def evaluate(expr : String, vars : Hash(String, Any)) : Any
  StackMachine.new(expr).evaluate(vars)
end

describe StackMachine do
  it "parses an empty string" do
    compile("").should eq("")
  end

  it "parses a blank string" do
    compile("  ").should eq("")
    compile(" \t ").should eq("")
  end

  it "parses string literals" do
    compile("'foo'").should eq("PushLiteral foo;")
    compile("\"foo\"").should eq("PushLiteral foo;")
    compile("'fo\\'o'").should eq("PushLiteral fo'o;")
    compile("\"fo\\\"o\"").should eq("PushLiteral fo\"o;")
  end

  it "raises on unclosed string literals" do
    ["'foo", "'foo\\'", "\"foo", "\"foo\\\""].each do |test_string|
      expect_raises(Exception, "Unterminated string literal.") do
        compile(test_string)
      end
    end
  end

  it "recognize \n" do
    compile("'\\n'").should eq("PushLiteral \n;")
  end

  it "recognize \t" do
    compile("'\\t'").should eq("PushLiteral \t;")
  end

  it "parses 'foo'" do
    compile("foo").should eq("PushVar foo;")
  end

  it "parses '-foo'" do
    compile("-foo").should eq("PushInvertion;PushVar foo;")
  end

  it "parses 'foo[-42]'" do
    compile("foo[-42]").should eq("PushVar foo;PushLiteral -42;IndexCall;")
  end

  it "parses 'foo[42]'" do
    compile("foo[42]").should eq("PushVar foo;PushLiteral 42;IndexCall;")
  end

  it "parses '!foo'" do
    compile("!foo").should eq("PushNegation;PushVar foo;")
  end

  it "parses 'foo.bar'" do
    compile("foo.bar").should eq("PushVar foo;Call bar;")
  end

  it "parses 'foo.bar.hey'" do
    compile("foo.bar.hey").should eq("PushVar foo;Call bar;Call hey;")
  end

  it "parses 'foo[0]'" do
    compile("foo[0]").should eq("PushVar foo;PushLiteral 0;IndexCall;")
  end

  it "parses 'foo[hey]'" do
    compile("foo[hey]").should eq("PushVar foo;PushVar hey;IndexCall;")
  end

  it "parses 'foo[\"hey\"]'" do
    compile("foo[\"hey\"]").should eq("PushVar foo;PushLiteral hey;IndexCall;")
  end

  it "parses 'foo[hey.ho]'" do
    compile("foo[hey.ho]").should eq("PushVar foo;PushVar hey;Call ho;IndexCall;")
  end

  it "parses 'foo[hey.ho[foo[2]]'" do
    compile("foo[hey.ho[foo[2]]").should eq("PushVar foo;PushVar hey;Call ho;PushVar foo;PushLiteral 2;IndexCall;IndexCall;")
  end

  it "parses 'foo[2].bar'" do
    compile("foo[2].bar").should eq("PushVar foo;PushLiteral 2;IndexCall;Call bar;")
  end

  it "evaluate 'foo'" do
    evaluate("foo", Hash{"foo" => Any.new(42)}).should eq(Any.new(42))
  end

  it "evaluate 'bar', not in context" do
    expect_raises(KeyError, "Key \"bar\" not found") do
      evaluate("bar", Hash{"foo" => Any.new(42)})
    end
  end

  it "evaluate 'foo.blank?'" do
    evaluate("foo.blank?", Hash{"foo" => Any.new("")}).should eq(Any.new(true))
  end

  it "evaluate 'foo.size'" do
    evaluate("foo.size", Hash{"foo" => Any.new("123")}).should eq(Any.new(3))
  end

  it "evaluate 'foo[0]'" do
    evaluate("foo[0]", Hash{"foo" => Any{42}}).should eq(Any.new(42))
  end

  it "evaluate 'foo[hey]'" do
    evaluate("foo[hey]", Hash{"foo" => Any{"bar" => "ok"}, "hey" => Any.new("bar")}).should eq(Any.new("ok"))
  end

  it "evaluate 'foo[\"bar\"]'" do
    evaluate("foo[\"bar\"]", Hash{"foo" => Any{"bar" => "ok"}}).should eq(Any.new("ok"))
  end

  it "evaluate 'foo[hey.ho]'" do
    evaluate("foo[hey.ho]", Hash{"foo" => Any{Any.new(true)}, "hey" => Any{"ho" => 0}}).should eq(Any.new(true))
  end

  context "when foo is a Drop" do
    it "evaluate 'drop.text'" do
      evaluate("drop.text", Hash{"drop" => Any.new(TextDrop.new)}).should eq(Any.new("text from drop"))
    end

    it "evaluate 'drop[\"text\"]'" do
      evaluate("drop[\"text\"]", Hash{"drop" => Any.new(TextDrop.new)}).should eq(Any.new("text from drop"))
    end

    it "evaluate 'product.texts.array[1]'" do
      evaluate("product.texts.array[1]", Hash{"product" => Any.new(ProductDrop.new)}).should eq(Any.new("text1"))
    end

    it "evaluate 'drop.text' when Drop inherits another Drop" do
      evaluate("drop.text", Hash{"drop" => Any.new(SuperTextDrop.new)}).should eq(Any.new("text from drop"))
    end

    it "doesn't export private methods" do
      expect_raises(Exception, "Method private_method not found for TextDrop.") do
        evaluate("drop.private_method", Hash{"drop" => Any.new(TextDrop.new)})
      end
    end

    it "doesn't export protected methods" do
      expect_raises(Exception, "Method protected_method not found for TextDrop.") do
        evaluate("drop.protected_method", Hash{"drop" => Any.new(TextDrop.new)})
      end
    end
  end
end
