require "./spec_helper"
require "../src/liquid/json"

describe Context do
  it "can set vars using JSON::Any" do
    ctx = Context.new(:strict)
    ctx.set("var", JSON.parse("true"))
    ctx.get("var").should eq(Any.new(true))

    ctx.set("var", JSON.parse("[1, 2.0, \"three\"]"))
    ctx.get("var").should eq(Any{1, 2.0, "three"})

    ctx.set("var", JSON.parse("{\"foo\": 42}"))
    ctx.get("var").should eq(Any{"foo" => 42})

    ctx.set("var", JSON.parse("null"))
    ctx.get("var").should eq(Any.new(nil))
  end
end
