require "./spec_helper"

include Liquid
include Liquid::Filters

describe Liquid::Filters do
  describe FilterRegister do
    it "should have registered default filters" do
      FilterRegister.get("abs").should eq Abs
      FilterRegister.get("append").should eq Append
      FilterRegister.get("camelcase").should eq CamelCase
      FilterRegister.get("camelize").should eq CamelCase
      FilterRegister.get("capitalize").should eq Capitalize
      FilterRegister.get("ceil").should eq Ceil
      FilterRegister.get("compact").should eq Compact
      FilterRegister.get("default").should eq Default
      FilterRegister.get("divided_by").should eq DividedBy
      FilterRegister.get("downcase").should eq Downcase
      FilterRegister.get("escape").should eq Escape
      FilterRegister.get("escape_once").should eq EscapeOnce
      FilterRegister.get("first").should eq First
      FilterRegister.get("floor").should eq Floor
      FilterRegister.get("join").should eq Join
      FilterRegister.get("last").should eq Last
      FilterRegister.get("lstrip").should eq LStrip
      FilterRegister.get("map").should eq Map
      FilterRegister.get("minus").should eq Minus
      FilterRegister.get("modulo").should eq Modulo
      FilterRegister.get("newline_to_br").should eq NewLineToBr
      FilterRegister.get("strip_newlines").should eq StripNewLines
      FilterRegister.get("pluralize").should eq Pluralize
      FilterRegister.get("plus").should eq Plus
      FilterRegister.get("remove").should eq Remove
      FilterRegister.get("remove_first").should eq RemoveFirst
      FilterRegister.get("replace").should eq Replace
      FilterRegister.get("replace_first").should eq ReplaceFirst
      FilterRegister.get("reverse").should eq Reverse
      FilterRegister.get("round").should eq Round
      FilterRegister.get("rstrip").should eq RStrip
      FilterRegister.get("size").should eq Size
      FilterRegister.get("slice").should eq StrSlice
      FilterRegister.get("split").should eq Split
      FilterRegister.get("strip").should eq Strip
      FilterRegister.get("strip_html").should eq StripHtml
      FilterRegister.get("underscore").should eq Underscore
      FilterRegister.get("upcase").should eq UpCase
      FilterRegister.get("uppercase").should eq UpCase
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

  describe CamelCase do
    it "should camelcase a string" do
      CamelCase.filter(Any.new "active_model").should eq "ActiveModel"
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

  describe EscapeOnce do
    it "should escape specials chars" do
      EscapeOnce.filter(Any.new "Me, myself & I").should eq "Me, myself &amp; I"
      EscapeOnce.filter(Any.new "Me, myself &amp; I &#33; &#33;").should eq "Me, myself &amp; I &#33; &#33;"
      EscapeOnce.filter(Any.new "Me, myself && &amp; I &#33; &#33;").should eq "Me, myself &amp;&amp; &amp; I &#33; &#33;"
    end
  end

  describe First do
    it "should return first result of an array" do
      a = [false, 1, "two"].to_json
      empty = [] of String
      First.filter(JSON.parse(a)).should eq false
      First.filter(JSON.parse(empty.to_json)).should eq empty
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

  describe LStrip do
    it "should return string with leading whitespace stripped" do
      LStrip.filter(Any.new "   mystring").should eq "mystring"
    end
  end

  describe Map do
    it "should return the property of the array of hashes & hash values" do
      d1 = JSON.parse({"category" => "yoo"}.to_json)
      d2 = JSON.parse([{"category" => "yoo"}, {"category" => "another"}].to_json)
      Map.filter(d1, [Any.new "category"]).should eq "yoo"
      Map.filter(d2, [Any.new "category"]).should eq ["yoo", "another"]
      Map.filter(d2, [Any.new "test"]).should eq [{"category" => "yoo"}, {"category" => "another"}]
    end
  end

  describe Minus do
    it "should should subtract numbers" do
      Minus.filter(Any.new(10), Array{Any.new (2)}).should eq 8
      Minus.filter(Any.new(10), Array{Any.new(2.0)}).should eq 8.0
      Minus.filter(Any.new("10"), Array{Any.new(2.0)}).should eq "10"
    end
  end

  describe Modulo do
    it "should return the modulo of two numbers" do
      Modulo.filter(Any.new(10), Array{Any.new(3)}).should eq 1
      Modulo.filter(Any.new(10.0), Array{Any.new(3)}).should eq 1.0
      Modulo.filter(Any.new(10.0), Array{Any.new(3.0)}).should eq 1.0
      Modulo.filter(Any.new(10), Array{Any.new(3.0)}).should eq 10
    end
  end

  describe NewLineToBr do
    it "should replace newline \\n by <br />" do
      NewLineToBr.filter(Any.new "Hello\nWorld").should eq "Hello<br />World"
    end
  end

  describe StripNewLines do
    it "should replace newline \\n by empty string" do
      StripNewLines.filter(Any.new "\nHello\n\nWorld\n").should eq "HelloWorld"
    end
  end

  describe Pluralize do
    it "should pluralize a string" do
      Pluralize.filter(Any.new "post").should eq "posts"
    end
  end

  describe Plus do
    it "should should add numbers" do
      Plus.filter(Any.new(10), Array{Any.new (2)}).should eq 12
      Plus.filter(Any.new(10), Array{Any.new(2.0)}).should eq 12.0
      Plus.filter(Any.new(10.0), Array{Any.new(2)}).should eq 12.0
      Plus.filter(Any.new(10.0), Array{Any.new(2.0)}).should eq 12.0
      Plus.filter(Any.new(10), Array{Any.new(4.30)}).should eq 14.3
      Plus.filter(Any.new("10"), Array{Any.new(2.0)}).should eq "10"
    end
  end

  describe Prepend do
    it "should prepend a string at the beginning of another" do
      Prepend.filter(Any.new("/index.html"), [Any.new "www.example.com"]).should eq "www.example.com/index.html"
    end
  end

  describe Remove do
    it "should remove every occurence from the current string" do
      Remove.filter(Any.new("I strained to see the train through the rain"), [Any.new "rain"]).should eq "I sted to see the t through the "
    end
  end

  describe RemoveFirst do
    it "should remove the first occurence from the current string" do
      RemoveFirst.filter(Any.new("I strained to see the train through the rain"), [Any.new "rain"]).should eq "I sted to see the train through the rain"
    end
  end

  describe Replace do
    it "should replace all occurences from the current string" do
      Replace.filter(Any.new("Take my protein pills and put my helmet on"), [Any.new("my"), Any.new("your")]).should eq "Take your protein pills and put your helmet on"
    end
  end

  describe ReplaceFirst do
    it "should replace the first occurence from the current string" do
      ReplaceFirst.filter(Any.new("Take my protein pills and put my helmet on"), [Any.new("my"), Any.new("your")]).should eq "Take your protein pills and put my helmet on"
    end
  end

  describe Reverse do
    it "should reverse an array" do
      d = [1, 2, 3].to_json
      Reverse.filter(JSON.parse(d)).should eq [3, 2, 1]
    end
  end

  describe Round do
    it "should round to the nearest precision in decimal digits" do
      Round.filter(Any.new 1.5242).should eq 2.0
      Round.filter(Any.new(1.5242), [Any.new(2)]).should eq 1.52
      Round.filter(Any.new("1.5242"), [Any.new(2)]).should eq "1.5242"
    end
  end

  describe RStrip do
    it "should return string with following whitespace stripped" do
      RStrip.filter(Any.new "   mystring     ").should eq "   mystring"
    end
  end

  describe Size do
    it "returns the size of a string, array or hash or return 0" do
      arr = [1, 2, 3, "4"]
      hash = {"example" => "hash", :blah => "wut"}

      Size.filter(Any.new(10)).should eq 0
      Size.filter(Any.new("example")).should eq 7
      Size.filter(JSON.parse(arr.to_json)).should eq 4
      Size.filter(JSON.parse(hash.to_json)).should eq 2
    end
  end

  describe StrSlice do
    it "should return substring of the current string value" do
      StrSlice.filter(Any.new("valuable"), [Any.new(4)]).should eq "able"
      StrSlice.filter(Any.new("valuable"), [Any.new(10)]).should eq "valuable"
      StrSlice.filter(Any.new("valuable"), [Any.new(2), Any.new(4)]).should eq "lua"
      StrSlice.filter(Any.new("valuable"), [Any.new(2), Any.new("test")]).should eq "luable"
    end
  end

  describe Split do
    it "split a string into an array" do
      Split.filter(Any.new("John, Paul, George, Ringo"), [Any.new ", "])
        .should eq ["John", "Paul", "George", "Ringo"]
    end
  end

  describe Strip do
    it "should remove whitespace from around string" do
      Strip.filter(Any.new "          So much room for activities!          ").should eq "So much room for activities!"
      Strip.filter(Any.new " ab c  ").should eq "ab c"
      Strip.filter(Any.new " \tab c  \n \t").should eq "ab c"
    end
  end

  describe StripHtml do
    it "should return string with HTML stripped" do
      StripHtml.filter(Any.new "<a href='#'>mystring</a>my<br/>String").should eq "mystringmyString"
      StripHtml.filter(Any.new "<b>bla blub</a>").should eq "bla blub"
      StripHtml.filter(Any.new "<!-- split and some <ul> tag --><b>bla blub</a>").should eq "bla blub"
    end
  end

  describe Underscore do
    it "should underscore a string" do
      Underscore.filter(Any.new "ActiveModel").should eq "active_model"
    end
  end

  describe UpCase do
    it "should uppercase a string" do
      UpCase.filter(Any.new "some words").should eq "SOME WORDS"
    end
  end
end
