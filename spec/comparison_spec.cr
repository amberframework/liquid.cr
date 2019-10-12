require "./spec_helper"

describe Liquid::BinOperator do
  it "should compare Boolean" do
    BinOperator.process("==", Any.new(true), Any.new(true)).should eq Any.new true
    BinOperator.process("==", Any.new(false), Any.new(false)).should eq Any.new true
    BinOperator.process("==", Any.new(false), Any.new(true)).should eq Any.new false
    BinOperator.process("==", Any.new(true), Any.new(false)).should eq Any.new false
  end

  it "should compare Numbers" do
    BinOperator.process("<", Any.new(12), Any.new(15)).should eq Any.new true
    BinOperator.process(">", Any.new(12), Any.new(15)).should eq Any.new false
  end

  it "should compare Time" do
    BinOperator.process("<=", Any.new(Time.utc), Any.new(Time.utc)).should eq Any.new true
    t = Time.utc
    BinOperator.process("==", Any.new(t), Any.new(t)).should eq Any.new true
  end
end
