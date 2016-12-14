require "./filters/*"
require "./context" 

module Liquid::Filters


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
