require "./spec_helper"

include Liquid
include Liquid::Filters

describe Liquid::Filters do
  describe FilterRegister do
    it "should have registered default filters" do
      FilterRegister.get("abs").should eq Abs
      FilterRegister.get("append").should eq Append
      FilterRegister.get("capitalize").should eq Capitalize
      FilterRegister.get("ceil").should eq Ceil
      FilterRegister.get("compact").should eq Compact
      FilterRegister.get("default").should eq Default
      FilterRegister.get("divided_by").should eq DividedBy
      FilterRegister.get("downcase").should eq Downcase
      FilterRegister.get("escape").should eq Escape
      FilterRegister.get("first").should eq First
      FilterRegister.get("floor").should eq Floor
      FilterRegister.get("join").should eq Join
      FilterRegister.get("last").should eq Last
      FilterRegister.get("newline_to_br").should eq NewLineToBr
      FilterRegister.get("split").should eq Split
    end
  end

  describe Replace do
    it "should replace" do
      Replace.filter(Any.new("Toto"), [Any.new("o"), Any.new("a")]).should eq "Tata"
    end
  end

  describe Abs do
    it "filter var and return absolute value" do
      Abs.filter(Any.new -12).should eq 12
      Abs.filter(Any.new 12).should eq 12
      Abs.filter(Any.new "wrong").should eq "wrong"
      Abs.filter(Any.new "-21.25").should eq 21.25
    end
  end

  describe Append do
    it "should append a string at the end of another" do
      Append.filter(Any.new("hello"), [Any.new " world"]).should eq "hello world"
    end
  end

  describe Capitalize do
    it "should capitalize a string" do
      Capitalize.filter(Any.new "my great title").should eq "My great title"
    end
  end

  describe Ceil do
    it "should ceil a number" do
      Ceil.filter(Any.new 1.2).should eq 2
      Ceil.filter(Any.new 2.0).should eq 2
      Ceil.filter(Any.new 183.357).should eq 184
      Ceil.filter(Any.new "3.5").should eq 4
    end
  end

  describe Compact do
    it "should remove all nil values from array" do
      a = [nil, true, "other", 1, nil, nil, nil, "wuddup!"].to_json
      expected = [true, "other", 1, "wuddup!"]
      Compact.filter(JSON.parse(a)).should eq expected
    end
  end

  describe Date do
    it "should format the date" do
      time = Time.new(2016, 2, 15, 10, 20, 30) # => 2016-02-15 10:20:30 UTC
      Date.filter(Any.new(time), Array{Any.new "%a, %b %d, %y"}).should eq "Mon, Feb 15, 16"
      Date.filter(Any.new(time), Array{Any.new "%Y"}).should eq "2016"
      Date.filter(Any.new("now"), Array{Any.new "%Y-%m-%d %H:%M"}).should eq Time.now.to_s "%Y-%m-%d %H:%M"
    end
  end

  describe Default do
    it "should return default value if false, nil or empty" do
      Default.filter(Any.new(nil), Array{Any.new 2.99}).should eq 2.99
      Default.filter(Any.new(4.99), Array{Any.new 2.99}).should eq 4.99
      Default.filter(Any.new(""), Array{Any.new 2.99}).should eq 2.99
      Default.filter(Any.new(false), Array{Any.new true}).should be_true
    end
  end

  describe DividedBy do
    it "should divide Number's by the appropriate value and not matching 0" do
      DividedBy.filter(Any.new(10), Array{Any.new 4}).should eq 2
      DividedBy.filter(Any.new(10), Array{Any.new 4.0}).should eq 2.5
      DividedBy.filter(Any.new(10.0), Array{Any.new 4}).should eq 2.5
      DividedBy.filter(Any.new(10.0), Array{Any.new 4.0}).should eq 2.5
    end

    it "should raise error if missing arguments or passing zero" do
      expect_raises(FilterArgumentException) do
        DividedBy.filter(Any.new(10))
        DividedBy.filter(Any.new(10), Array{Any.new 0})
      end
    end
  end

  describe Downcase do
    it "should lowercase the string" do
      Downcase.filter(Any.new "This_Is_MY_cusTom_slug").should eq "this_is_my_custom_slug"
    end
  end

  describe Escape do
    it "should escape specials chars" do
      Escape.filter(Any.new "Have you read 'James & the Giant Peach'?").should eq "Have you read &#39;James &amp; the Giant Peach&#39;?"
      Escape.filter(Any.new "Tetsuro Takara").should eq "Tetsuro Takara"
    end
  end

  describe First do
    it "should return first result of an array" do
      a = [false, 1, "two"].to_json
      First.filter(JSON.parse(a)).should eq false
    end
  end

  describe Floor do
    it "should floor float data" do
      Floor.filter(Any.new "242.34").should eq 242.0
      Floor.filter(Any.new 242.47).should eq 242.0
      Floor.filter(Any.new 242).should eq 242
    end
  end

  describe Join do
    it "join (yes)" do
      n = ["John", "Paul", "George", "Ringo"].to_json
      Join.filter(JSON.parse(n), [Any.new " and "]).should eq "John and Paul and George and Ringo"
    end
  end

  describe Last do
    it "should return the last item in an array that isn't empty" do
      a = ["one", "two", "three"].to_json
      empty = [] of String
      Last.filter(JSON.parse(a)).should eq "three"
      Last.filter(JSON.parse(empty.to_json)).should eq empty
    end
  end

  describe NewLineToBr do
    it "should replace newline \\n by <br />" do
      NewLineToBr.filter(Any.new "Hello\nWorld").should eq "Hello<br />World"
    end
  end

  describe Split do
    it "split a string into an array" do
      Split.filter(Any.new("John, Paul, George, Ringo"), [Any.new ", "])
           .should eq ["John", "Paul", "George", "Ringo"]
    end
  end
end
