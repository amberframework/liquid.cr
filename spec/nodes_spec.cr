require "./spec_helper"

describe Liquid::Nodes do

  describe For do
    it "should loop over array" do
      stmt = For.new Tokens::ForStatement.new "for x in myarray"
      stmt << Expression.new "x"
      ctx = Context.new
      ctx.set("myarray", ["apple", 12])
      node_output(stmt, ctx).should eq "apple12"
    end
  end

  describe Capture do
    it "should capture the content of the block" do
      block = Capture.new "capture mavar"
      block << Raw.new "Hello World!"
      ctx = Context.new
      node_output(block, ctx)
      ctx.get("mavar").should eq "Hello World!"
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

  describe Filtered do
    it "should filter a string" do
      node = Filtered.new " \"whatever\" | abs"
      ctx = Context.new
      io = IO::Memory.new
      node.render(ctx, io)
      io.close
      io.to_s.should eq "whatever"
    end

    it "should filter a int" do
      node = Filtered.new "-12 | abs"
      ctx = Context.new
      io = IO::Memory.new
      node.render(ctx, io)
      io.close
      io.to_s.should eq "12"
    end

    it "should filter a float" do
      node = Filtered.new "-12.25 | abs"
      ctx = Context.new
      io = IO::Memory.new
      node.render(ctx, io)
      io.close
      io.to_s.should eq "12.25"
    end

    it "should filter a var" do
      node = Filtered.new "var | abs"
      ctx = Context.new
      ctx.set "var", -12
      io = IO::Memory.new
      node.render(ctx, io)
      io.close
      io.to_s.should eq "12"
    end

    it "should use multiple filters" do
      node = Filtered.new "var | append: \"Hello \" | append: \"World !\""
      ctx = Context.new
      ctx.set "var", ""
      io = IO::Memory.new
      node.render(ctx, io)
      io.close
      io.to_s.should eq "Hello World !"
    end

    it "should filter with an argument" do
      node = Filtered.new "var | append: var2"
      ctx = Context.new
      ctx.set "var", "Hello"
      ctx.set "var2", " World !"
      io = IO::Memory.new
      node.render(ctx, io)
      io.close
      io.to_s.should eq "Hello World !"
    end

  end

  describe Expression do
    it "should eval true" do
      expr = Expression.new "true"
      expr.eval(Context.new).should be_true
    end

    it "should eval false" do
      expr = Expression.new "false"
      expr.eval(Context.new).should be_false
    end

    it "should eval float" do
      expr = Expression.new "12.5"
      expr2 = Expression.new "-120.5"
      expr.eval(Context.new).should eq 12.5
      expr2.eval(Context.new).should eq -120.5
    end

    it "should eval a var" do
      expr = Expression.new "myvar"
      expr2 = Expression.new "myvar.inner"
      expr3 = Expression.new "myvar.inner.inner"

      ctx = Context.new
      ctx.set("myvar", true)
      ctx.set("myvar.inner", false)
      ctx.set("myvar.inner.inner", "good")

      expr.eval(ctx).should be_true
      expr2.eval(ctx).should be_false
      expr3.eval(ctx).should eq "good"
    end

    it "should eval an comparison" do
      expr = Expression.new "true == false"
      expr2 = Expression.new "true != false"
      expr3 = Expression.new "var != 15"

      ctx = Context.new
      ctx.set "var", 16

      expr.eval(ctx).should be_false
      expr2.eval(ctx).should be_true
      expr3.eval(ctx).should be_true
    end
    # it "should eval an operation with contains keyword" do
    #   expr = Expression.new "myarr contains another"
    #   ctx = Context.new
    #   ctx.set "myarr", [12,15,13]
    #   ctx.set "another", 12
    #   expr.eval(ctx).should be_true
    # end
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
