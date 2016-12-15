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
end
