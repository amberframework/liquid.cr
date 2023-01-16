require "./base"

module Liquid::Filters
  class Last
    extend Filter

    def self.filter(data : Any, args : Array(Any), options : Hash(String, Any)) : Any
      if (d = data.as_a?) && !d.empty?
        d.last
      else
        data
      end
    end
  end

  FilterRegister.register "last", Last
end
