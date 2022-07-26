require "./spec_helper"

describe Liquid do
  describe Context do
    it "should allow to add hash to context" do
      hash = Any{"test" => "truc"}
      ctx = Context.new
      ctx.set "val", hash
      ctx.get("val").should eq hash
    end

    it "should add array to context" do
      ctx = Context.new
      ctx.set "val", Any{"str", 12}
      ctx["val"].should eq Any{"str", 12}
    end

    it "should add hash to context" do
      ctx = Context.new
      ctx.set "hash", Any{"some" => "thing", "another" => 12}
      ctx["hash"].should eq(Any{"some" => "thing", "another" => 12})
      ctx["hash.some"].should eq "thing"
      ctx["hash.another"].should eq 12
    end

    it "should add hash of hash to context" do
      ctx = Context.new
      ctx.set "hash", Any{"sub" => Any{"val" => true, "or" => "false"}}
      ctx["hash.sub.val"].should be_true
    end

    it "should add array of hash to context" do
      ctx = Context.new
      ctx.set "arr", Any{Any{"some" => true, "egg" => 1, "foo" => "bar"}}
      ctx["arr"][0]["some"].should be_true
      ctx["arr"][0]["foo"].should eq "bar"
    end

    it "returns nil for missing key in normal mode" do
      ctx = Context.new
      ctx.get("missing").should be_nil
      ctx.get("obj.missing").should be_nil
    end

    it "raises on missing key in strict mode" do
      ctx = Context.new(strict: true)
      expect_raises(KeyError) { ctx.get("missing") }
      expect_raises(KeyError) { ctx.get("obj.missing") }
      ctx["obj"] = Any{"something" => "something"}
      expect_raises(KeyError) { ctx.get("obj.missing") }
    end

    pending "returns nil for missing key in strict mode with ?" do
      ctx = Context.new(strict: true)
      ctx.get("missing?").should be_nil
      ctx.get("obj.missing?").should be_nil
    end
  end
end
