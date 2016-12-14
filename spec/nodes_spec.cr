require "./spec_helper"

describe Liquid::Nodes do
  describe "Match Regex" do
    it "should match vars" do
      ok = ["mavar", "ma_var", "mavar2", "m646_dfd54"]
      err = ["2var", "Unexpected-", "not-me", "rage$"]
      ok.each &.match(/^#{VAR}$/).should_not be_nil
      err.each &.match(/^#{VAR}$/).should be_nil
    end

    it "should match String, int and float" do
      ok = ["\"\"", "\"not empty string\"", "12", "-12", "15.68", "-20.36"]
      err = ["\"\"\"", "\"doo bi \" YOLO \" doop\"", "--545", "54.54.5", "115-"]
      ok.each &.match(/^#{TYPE}$/).should_not be_nil
      err.each &.match(/^#{TYPE}$/).should be_nil
    end

    it "should match a type or a var" do
      ok = ["\"\"", "\"not empty string\"", "12", "-12", "15.68", "-20.36", "ma_var"]
      err = ["\"\"\"", "\"doo bi \" YOLO \" doop\"", "--545", "54.54.5", "115-", "not-me", "-troll"]
      ok.each &.match(/^#{TYPE_OR_VAR}$/).should_not be_nil
      err.each &.match(/^#{TYPE_OR_VAR}$/).should be_nil
    end

    it "should match a comparison" do
      ok = ["a == b", "sdf != fds", "dd < 12", "true > false", "hh==hh", "12 <= var"]
      err = ["a = b", "dfs ! fff", "ddd=ddd", "12>"]
      ok.each &.match(/^#{CMP}$/).should_not be_nil
      err.each &.match(/^#{CMP}$/).should be_nil
    end

    it "should match filters" do
      ok = ["a | b", "a | b | v", "-12 | abs", "\"toto\" | abs"]
      err = ["a ||", "dfs |", "|ddd=ddd", "1|2", "dd | 12"]
      ok.each &.match(/^#{FILTERED}$/).should_not be_nil
      err.each &.match(/^#{FILTERED}$/).should be_nil
    end
  end

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
