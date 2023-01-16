require "./base"

module Liquid::Filters
  class First
    extend Filter

    def self.filter(data : Any, args : Array(Any), options : Hash(String, Any)) : Any
      if (d = data.as_a?) && !d.empty?
        d.first
      else
        data
      end
    end
  end

  FilterRegister.register "first", First
end
