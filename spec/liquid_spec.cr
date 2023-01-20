require "./spec_helper"

describe Liquid::Context do
  it "can set and get data" do
    ctx = Context.new
    ctx["arr"] = Any{Any{"some" => true, "egg" => 1, "foo" => "bar"}}
    ctx["arr"][0]["some"].should be_true
    ctx["arr"][0]["foo"].should eq "bar"
  end

  it "returns nil for missing key on []?" do
    ctx = Context.new
    ctx["missing"]?.should be_nil
  end

  it "returns nil for missing key when not in strict mode" do
    ctx = Context.new
    ctx["missing"]?.should be_nil
  end

  it "returns nil for undefined variables on Lax mode" do
    ctx = Context.new(:lax)
    ctx.get("missing").raw.should eq(nil)
    ctx.errors.should be_empty
  end

  it "does not raise for undefined variables on strict mode" do
    ctx = Context.new(:strict)
    ctx.get("missing").raw.should eq(nil)
    ctx.errors.map(&.message).should eq([%(Liquid error: Undefined variable: "missing".)])
    ctx.errors.map(&.class).should eq([Liquid::UndefinedVariable])
  end

  it "store errors for undefined variables in warn mode" do
    ctx = Context.new(:warn)
    ctx.get("missing").raw.should eq(nil)
    ctx.errors.map(&.message).should eq([%(Liquid error: Undefined variable: "missing".)])
    ctx.errors.map(&.class).should eq([Liquid::UndefinedVariable])
  end
end
