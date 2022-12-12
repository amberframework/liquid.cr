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

  it "raises on missing key in strict mode" do
    ctx = Context.new(:strict)
    ctx["obj"] = Any{"something" => "something"}
    expect_raises(InvalidExpression) { ctx.get("missing") }
    expect_raises(InvalidExpression) { ctx.get("obj.missing") }
  end

  it "returns nil for missing key on Lax mode" do
    ctx = Context.new(:lax)
    ctx.get("missing").raw.should eq(nil)
  end

  it "returns nil for missing key on Warn mode" do
    ctx = Context.new(:warn)
    ctx.get("missing").raw.should eq(nil)
    ctx.errors.should eq([%(Variable "missing" not found.)])
  end
end
