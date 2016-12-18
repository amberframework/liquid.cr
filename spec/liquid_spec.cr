require "./spec_helper"

describe Liquid::Context do
  it "should allow to add hash to context" do
    hash = Any.new Hash(String, Type){"test" => "truc"}
    ctx = Context.new
    ctx.set "val", hash
    ctx.get("val").should eq hash
  end

  it "should add array to context" do
    ctx = Context.new
    ctx.set "val", ["str", 12]
    ctx["val"].should eq ["str", 12]
  end

  it "should add hash to context" do
    ctx = Context.new
    ctx.set "hash", { "some" => "thing", "another" => 12}
    ctx["hash"].should eq({ "some" => "thing", "another" => 12})
    ctx["hash.some"].should eq "thing"
    ctx["hash.another"].should eq 12
  end

  it "should add hash of hash to context" do
    ctx = Context.new
    ctx.set "hash", { "sub" => {"val" => true} }
    ctx["hash.sub.val"].should be_true
  end

end
