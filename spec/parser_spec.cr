require "./spec_helper"

describe Liquid::Parser do
  it "catch syntax errors reported by nodes" do
    e = expect_raises(Liquid::SyntaxError) do
      Liquid::Parser.parse("\n\n{% increment () %}")
    end
    e.line_number.should eq(3)
  end

  it "report unknown tags as syntax errors" do
    e = expect_raises(Liquid::SyntaxError, "Unknown tag 'asdf'.") do
      Liquid::Parser.parse("{% asdf %}")
    end
    e.line_number.should eq(1)
  end
end
