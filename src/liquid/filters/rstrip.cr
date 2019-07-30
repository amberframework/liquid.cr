require "./base"

module Liquid::Filters
  class RStrip
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      if (str = data.as_s?)
        Any.new str.rstrip
      else
        data
      end
    end
  end

  FilterRegister.register "rstrip", RStrip
end
