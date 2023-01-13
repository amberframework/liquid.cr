require "./spec_helper"

module Liquid
  describe "Match Regex" do
    it "should match vars" do
      ok = ["mavar", "ma_var", "mavar2", "m646_dfd54", "_tagazok"]
      err = ["2var", "Unexpected-", "not-me", "rage$"]
      ok.each &.match(/^#{VAR}$/).should_not be_nil
      err.each &.match(/^#{VAR}$/).should be_nil
    end

    it "should match String, int and float" do
      ok = ["\"\"", "''", "'not empty string'", "\"not empty string\"", "0", "0.0", "12", "-12", "15.68", "-20.36"]
      err = ["\"\"\"", "'", "'''", "'don't'", "\"doo bi \" YOLO \" doop\"", "54.54.5", "115-"]
      ok.each &.match(/^#{TYPE}$/).should_not be_nil
      err.each &.match(/^#{TYPE}$/).should be_nil
    end

    it "should match a type or a var" do
      ok = ["\"\"", "''", "'not empty string'", "\"not empty string\"", "0", "0.0", "12", "-12", "15.68", "-20.36", "ma_var"]
      err = ["\"\"\"", "'", "'''", "'don't'", "\"doo bi \" YOLO \" doop\"", "54.54.5", "115-", "not-me"]
      ok.each &.match(/^#{TYPE_OR_VAR}$/).should_not be_nil
      err.each &.match(/^#{TYPE_OR_VAR}$/).should be_nil
    end
  end
end
