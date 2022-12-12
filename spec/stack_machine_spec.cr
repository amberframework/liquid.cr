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

private def it_evaluates(expr : String, ctx : Context, expected : Liquid::Any::Type,
                         file = __FILE__, line = __LINE__)
  it "evaluates #{expr} with #{ctx} to #{expected}", file: file, line: line do
    StackMachine.new(expr).evaluate(ctx).should eq(Any.new(expected))
  end
end

private def it_raises(exception, message : String, expr : String, ctx : Context, file = __FILE__, line = __LINE__)
  it "raises #{exception}(#{message}) evaluating #{expr} with #{ctx}", file: file, line: line do
    expect_raises(exception, message) do
      StackMachine.new(expr).evaluate(ctx)
    end
  end
end

describe StackMachine do
  it_raises(InvalidExpression, "Variable \"bar\" not found", "bar", Context.new(:strict))

  it_evaluates("foo", Context{"foo" => Any.new(42)}, 42)
  it_evaluates("foo.blank?", Context{"foo" => Any.new("")}, true)
  it_evaluates("foo.size", Context{"foo" => Any.new("123")}, 3)
  it_evaluates("foo[0]", Context{"foo" => Any{42}}, 42)
  it_evaluates("foo[hey]", Context{"foo" => Any{"bar" => "ok"}, "hey" => Any.new("bar")}, "ok")
  it_evaluates("foo[\"bar\"]", Context{"foo" => Any{"bar" => "ok"}}, "ok")
  it_evaluates("foo[hey.ho]", Context{"foo" => Any{Any.new(true)}, "hey" => Any{"ho" => 0}}, true)
  it_evaluates("foo[0][1]", Context{"foo" => Any{Any{Any.new(1), Any.new(42)}}}, 42)
  it_evaluates("!foo", Context{"foo" => Any.new(true)}, false)

  it_evaluates("a == true", Context{"a" => Any.new(true)}, true)
  it_evaluates("a == true", Context{"a" => Any.new(false)}, false)
  it_evaluates("2 != 3", Context{"a" => Any.new(true)}, true)
  it_evaluates("2 != 2", Context{"a" => Any.new(false)}, false)
  it_evaluates("a > 2", Context{"a" => Any.new(2)}, false)
  it_evaluates("a > 2", Context{"a" => Any.new(3)}, true)
  it_evaluates("a >= 2", Context{"a" => Any.new(1)}, false)
  it_evaluates("a >= 2", Context{"a" => Any.new(2)}, true)
  it_evaluates("a < 2", Context{"a" => Any.new(2)}, false)
  it_evaluates("a < 2", Context{"a" => Any.new(1)}, true)
  it_evaluates("a <= 2", Context{"a" => Any.new(2)}, true)
  it_evaluates("a contains b", Context{"a" => Any{Any.new(1), Any.new(2)}, "b" => Any.new(1)}, true)
  it_evaluates("a contains b", Context{"a" => Any{Any.new(1), Any.new(2)}, "b" => Any.new(0)}, false)
  it_evaluates("a contains b", Context{"a" => Any.new("hey ho!"), "b" => Any.new("ey ")}, true)

  it_evaluates("a or true", Context{"a" => Any.new(false)}, true)
  it_evaluates("a or false", Context{"a" => Any.new(false)}, false)
  it_evaluates("a and true", Context{"a" => Any.new(true)}, true)
  it_evaluates("a and false", Context{"a" => Any.new(true)}, false)

  # From liquid reference
  it_evaluates("true or false and false", Context.new, true)
  it_evaluates("true and false and false or true", Context.new, false)

  # filters
  it_evaluates("'a, b, c' | split: ', ' | join '-' | upcase", Context.new, "A-B-C")

  context "when evaluating a Drop" do
    it_evaluates("drop.text", Context{"drop" => Any.new(TextDrop.new)}, "text from drop")
    it_evaluates("drop[\"text\"]", Context{"drop" => Any.new(TextDrop.new)}, "text from drop")
    it_evaluates("product.texts.array[1]", Context{"product" => Any.new(ProductDrop.new)}, "text1")
    it_evaluates("drop.text", Context{"drop" => Any.new(SuperTextDrop.new)}, "text from drop")

    it_raises(InvalidExpression, "Method private_method not found for TextDrop.",
      "drop.private_method", Context{"drop" => Any.new(TextDrop.new)})
    it_raises(InvalidExpression, "Method protected_method not found for TextDrop.",
      "drop.protected_method", Context{"drop" => Any.new(TextDrop.new)})
  end
end
