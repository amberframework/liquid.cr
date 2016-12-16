require "./spec_helper"

include Liquid::Filters

describe Liquid::Filters do

  describe FilterRegister do

    it "should have registered default filters" do
      FilterRegister.get("abs").should eq Abs
      FilterRegister.get("append").should eq Append
      FilterRegister.get("capitalize").should eq Capitalize
      FilterRegister.get("ceil").should eq Ceil
      FilterRegister.get("default").should eq Default
      FilterRegister.get("escape").should eq Escape
    end
    
  end
  
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

  describe Ceil do
    it "should ceil a number" do
      Ceil.filter(1.2).should eq 2
      Ceil.filter(2.0).should eq 2
      Ceil.filter(183.357).should eq 184
      Ceil.filter("3.5").should eq 4
    end
  end

  describe Date do
    it "should format the date" do
      time = Time.new(2016, 2, 15, 10, 20, 30) # => 2016-02-15 10:20:30 UTC
      Date.filter(time, Array{"%a, %b %d, %y"}).should eq "Mon, Feb 15, 16"
      Date.filter(time, Array{"%Y"}).should eq "2016"
      Date.filter("now", Array{"%Y-%m-%d %H:%M"}).should eq Time.now.to_s "%Y-%m-%d %H:%M"
    end
  end

  describe Default do
    it "should return default value if false, nil or empty" do
      Default.filter(nil, Array{2.99}).should eq 2.99
      Default.filter(4.99, Array{2.99}).should eq 4.99
      Default.filter("", Array{2.99}).should eq 2.99
      Default.filter(false, Array{true}).should be_true
    end
  end

  describe Escape do
    it "should escape specials chars" do
      Escape.filter("Have you read 'James & the Giant Peach'?").should eq "Have you read &#39;James &amp; the Giant Peach&#39;?"
      Escape.filter("Tetsuro Takara").should eq "Tetsuro Takara"
    end
  end
  
end
