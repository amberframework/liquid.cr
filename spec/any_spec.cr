require "./spec_helper"

describe Liquid::Any do
  it "determines if underlying value is a number or not" do
    any = Any.new(5)
    any.as_number?.should eq(5)

    any = Any.new(5.0)
    any.as_number?.should eq(5.0)

    any = Any.new("5.0")
    any.as_number?.should eq(5.0)

    any = Any.new("Hello, world!")
    any.as_number?.should be_nil
  end

  it "raises if underlying value is not a number" do
    expect_raises(TypeCastError, "Cast from String to Number+ failed") do
      any = Any.new("Hello, world!")
      any.as_number
    end
  end
end
