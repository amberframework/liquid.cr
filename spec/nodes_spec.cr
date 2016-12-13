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
  end
end
