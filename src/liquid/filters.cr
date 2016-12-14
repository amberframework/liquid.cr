require "./filters/*"
require "./context"

module Liquid::Filters
  class FilterRegister
    @@register = Hash(String, Filter).new

    def self.get(str : String)
      @@register[str]?
    end

    def self.register(name, filter)
      @@register[name] = filter
    end
  end

  FilterRegister.register "abs", Abs

  module Filter
    abstract def filter(data : Context::DataType) : Context::DataType
  end

  class Abs
    extend Filter

    def self.filter(data : Context::DataType) : Context::DataType
      if data.responds_to? :abs
        data.abs
      else
        data
      end
    end
  end
end
