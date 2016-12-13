require "./spec_helper"

describe Liquid::Nodes do
  describe Expression do
    it "should eval true" do
      expr = Expression.new Tokens::Expression.new("true")
      expr.eval(Context.new).should be_true
    end

    it "should eval false" do
      expr = Expression.new Tokens::Expression.new("false")
      expr.eval(Context.new).should be_false
    end

    it "should eval a var" do
      expr = Expression.new Tokens::Expression.new("myvar")
      expr2 = Expression.new Tokens::Expression.new("myvar.inner")
      expr3 = Expression.new Tokens::Expression.new("myvar.inner.inner")

      ctx = Context.new
      ctx.set("myvar", true)
      ctx.set("myvar.inner", false)
      ctx.set("myvar.inner.inner", "good")

      expr.eval(ctx).should be_true
      expr2.eval(ctx).should be_false
      expr3.eval(ctx).should eq "good"
    end

    it "should eval an operation" do
      expr = Expression.new Tokens::Expression.new("true == false")
      expr.eval(Context.new).should be_false
    end

    it "should assign a value" do
      expr = Expression.new "assign bool = true"
      expr2 = Expression.new "assign str = \"test\""
      expr3 = Expression.new "assign int = 12"
      ctx = Context.new

      expr.eval(ctx)
      expr2.eval(ctx)
      expr3.eval(ctx)

      ctx.get("bool").should be_true
      ctx.get("str").should eq "test"
      ctx.get("int").should eq 12
    end
  end
end
