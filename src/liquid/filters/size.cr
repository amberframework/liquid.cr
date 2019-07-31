require "./base"

module Liquid::Filters
  class Size
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      if (raw = data.raw) && raw.responds_to?(:size)
        Any.new raw.size
      else
        Any.new 0
      end
    end
  end

  FilterRegister.register "size", Size
end
