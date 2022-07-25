require "./base"

module Liquid::Filters
  class Compact
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      if d = data.as_a?
        Any.new(d.reject(&.raw.nil?))
      else
        data
      end
    end
  end

  FilterRegister.register "compact", Compact
end
