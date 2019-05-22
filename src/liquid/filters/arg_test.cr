require "json"
require "./base"

module Liquid::Filters
  class ArgTest
    extend Filter

    def self.filter(data : JSON::Any, args : Array(JSON::Any)? = nil) : JSON::Any
      if (a = args)
        JSON::Any.new(a.map(&.to_s).join(", "))
      else
        JSON::Any.new(nil)
      end
    end
  end

  FilterRegister.register "arg_test", ArgTest
end
