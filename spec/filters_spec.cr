require "./spec_helper"

include Liquid::Filters

describe Liquid::Filters do
  describe Abs do
    it "filter var and return absolute value" do
      Abs.filter(-12).should eq 12
      Abs.filter(12).should eq 12
      Abs.filter("wrong").should eq "wrong"
      Abs.filter("-21.25").should eq 21.25
    end
  end

  describe Append do
    it "should append a string at the end of another" do
      args = Array(Context::DataType).new
      args << " world"
      Append.filter("hello", args).should eq "hello world"
    end
  end

  describe Capitalize do
    it "should capitalize a string" do
      Capitalize.filter("my great title").should eq "My great title"
    end
  end
end
