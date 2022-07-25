require "./base"

module Liquid::Filters
  class ArgTest
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      if (a = args)
        Any.new(a.map(&.to_s).join(", "))
      else
        Any.new(nil)
      end
    end
  end

  FilterRegister.register "arg_test", ArgTest
end
