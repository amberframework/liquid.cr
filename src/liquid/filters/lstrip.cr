require "./base"

module Liquid::Filters
  class LStrip
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      if (str = data.as_s?)
        Any.new str.lstrip
      else
        data
      end
    end
  end

  FilterRegister.register "lstrip", LStrip
end
