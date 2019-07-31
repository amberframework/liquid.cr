require "./base"

module Liquid::Filters
  class Reverse
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      if (raw = data.raw) && raw.responds_to?(:reverse)
        Any.new raw.reverse
      else
        data
      end
    end
  end

  FilterRegister.register "reverse", Reverse
end
