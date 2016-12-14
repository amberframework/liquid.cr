require "./spec_helper"

describe Liquid::Nodes do
  describe For do
    it "should loop over array" do
      stmt = For.new Tokens::ForStatement.new "for x in myarray"
      stmt << Expression.new "x"
      ctx = Context.new
      ctx.set("myarray", ["apple", 12])
      io = IO::Memory.new
      stmt.render(ctx, io)
      io.close
      io.to_s.should eq "apple12"
    end
  end

  describe Assign do
    it "should assign a value" do
      expr = Assign.new "assign bool = true"
      expr2 = Assign.new "assign str = \"test\""
      expr3 = Assign.new "assign int = 12"
      ctx = Context.new

      expr.render(ctx, IO::Memory.new)
      expr2.render(ctx, IO::Memory.new)
      expr3.render(ctx, IO::Memory.new)

      ctx.get("bool").should be_true
      ctx.get("str").should eq "test"
      ctx.get("int").should eq 12
    end
  end

  describe Expression do
    it "should eval true" do
      expr = Expression.new Tokens::Expression.new("true")
      expr.eval(Context.new).should be_true
    end

    it "should eval false" do
      expr = Expression.new Tokens::Expression.new("false")
      expr.eval(Context.new).should be_false
    end

    it "should eval float" do
      expr = Expression.new "12.5"
      expr.eval(Context.new).should eq 12.5
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

    it "should eval an multiple operation" do
      expr = Expression.new "test == false or some == true or another == 10"
      expr2 = Expression.new "test != false or some == false or another == 10"
      expr3 = Expression.new "test != false and some != false and another == 15"
      ctx = Context.new
      ctx.set "test", true
      ctx.set "some", true
      ctx.set "another", 15
      expr.eval(ctx).should be_true
      expr2.eval(ctx).should be_true
      expr3.eval(ctx).should be_true
    end
  end
end
