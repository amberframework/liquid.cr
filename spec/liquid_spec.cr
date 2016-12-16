require "./spec_helper"

describe Liquid::Context do
  it "should allow to add array to context" do
    hash = Any.new Hash(String, Type){"test" => "truc"}
    ctx = Context.new
    ctx.set "val", hash
    ctx.get("val").should eq hash
  end
end
