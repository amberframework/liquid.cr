require "./spec_helper"

include Liquid::Filters

describe Liquid::Filters do

  describe Abs do

    it "filter var and return absolute value" do
      filtered = Abs.filter -12
      filtered.should eq 12

      Abs.filter(12).should eq 12
      Abs.filter("wrong").should eq "wrong"

    end

  end

end


