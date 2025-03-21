require "./base"

module Liquid::Filters
  class Strip
    extend Filter

    def self.filter(data : Any, args : Array(Any), options : Hash(String, Any)?) : Any
      if str = data.as_s?
        Any.new str.strip
      else
        data
      end
    end
  end

  FilterRegister.register "strip", Strip
end
