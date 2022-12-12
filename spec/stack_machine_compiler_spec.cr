require "./spec_helper"
require "../src/liquid/stack_machine_compiler"

private def compile(expr : String) : String
  StackMachineCompiler.compile(expr).join
end

private def it_compiles(expr : String, expected : String, file = __FILE__, line = __LINE__)
  it "compiles #{expr} to #{expected}", file: file, line: line do
    StackMachineCompiler.compile(expr).join.should eq(expected)
  end
end

private def it_raises(exception, message : String, expr : String, file = __FILE__, line = __LINE__)
  it "raises #{exception}(#{message}) compiling #{expr}", file: file, line: line do
    expect_raises(exception, message) do
      StackMachineCompiler.compile(expr)
    end
  end
end

describe StackMachineCompiler do
  it_compiles("", "")
  it_compiles(" \t ", "")
  it_compiles("'foo'", %(PushLiteral "foo";))
  it_compiles("\"foo\"", %(PushLiteral "foo";))
  it_compiles("'fo\\'o'", %(PushLiteral "fo'o";))
  it_compiles("\"fo\\\"o\"", %(PushLiteral "fo\\"o";))

  it_raises(Exception, "Unterminated string literal.", "'foo")
  it_raises(Exception, "Unterminated string literal.", "'foo\\'")
  it_raises(Exception, "Unterminated string literal.", "\"foo")
  it_raises(Exception, "Unterminated string literal.", "\"foo\\\"")

  it_compiles("'\\n'", %(PushLiteral "\\n";))
  it_compiles("'\\t'", %(PushLiteral "\\t";))

  it_compiles("3.1415", "PushLiteral 3.1415;")
  it_compiles("-3.1415", "PushLiteral -3.1415;")
  it_compiles("-42", "PushLiteral -42;")
  it_compiles("42", "PushLiteral 42;")

  it_compiles("foo", "PushVar foo;")
  it_compiles("-foo", "PushInvertion;PushVar foo;")
  it_compiles("foo[-42]", "PushVar foo;PushLiteral -42;IndexCall;")
  it_compiles("foo[42]", "PushVar foo;PushLiteral 42;IndexCall;")
  it_compiles("!foo", "PushNegation;PushVar foo;")

  it_compiles("foo.bar", "PushVar foo;Call bar;")
  it_compiles("foo.bar.hey", "PushVar foo;Call bar;Call hey;")

  it_compiles("foo[0]", "PushVar foo;PushLiteral 0;IndexCall;")
  it_compiles("foo[hey]", "PushVar foo;PushVar hey;IndexCall;")
  it_compiles("foo[\"hey\"]", %(PushVar foo;PushLiteral "hey";IndexCall;))
  it_compiles("foo[hey.ho]", "PushVar foo;PushVar hey;Call ho;IndexCall;")
  it_compiles("foo[hey.ho[foo[2]]", "PushVar foo;PushVar hey;Call ho;PushVar foo;PushLiteral 2;IndexCall;IndexCall;")
  it_compiles("foo[2].bar", "PushVar foo;PushLiteral 2;IndexCall;Call bar;")

  it_compiles("true false", "PushLiteral true;PushLiteral false;")

  # Filters
  it_compiles("a | foo", "PushVar a;Filter foo;")
  it_compiles("a | foo | bar", "PushVar a;Filter foo;Filter bar;")
  it_compiles("a | foo: 1, 2", "PushVar a;Filter foo;PushLiteral 1;PushLiteral 2;")

  # Comparison
  it_compiles("a == true", "PushVar a;Operator ==;PushLiteral true;")
  it_compiles("a contains b", "PushVar a;Operator contains;PushVar b;")
  it_compiles("a > b", "PushVar a;Operator >;PushVar b;")
  it_compiles("a >= b", "PushVar a;Operator >=;PushVar b;")
  it_compiles("a < b", "PushVar a;Operator <;PushVar b;")
  it_compiles("a <= b", "PushVar a;Operator <=;PushVar b;")
end
