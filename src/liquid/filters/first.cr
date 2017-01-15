require "./base"

module Liquid::Filters
  class First
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      if (d = data.as_a?) && !d.empty?
        Any.new d.first
      else
        data
      end
    end
  end

  FilterRegister.register "first", First
end