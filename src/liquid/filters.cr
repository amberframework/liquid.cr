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
  FilterRegister.register "append", Append

  module Filter
    abstract def filter(data : Context::DataType, arguments : Array(Context::DataType)?) : DataType
  end

  # Filter abs
  #
  # Returns the absolute value of a number.
  #
  # `{{ -17 | abs }}` => `17`
  #
  # `{{ 4 | abs }}` => `4`
  #
  # abs will also work on a string if the string only contains a number.
  #
  # `{{ "-19.86" | abs }}` => `19.86`
  class Abs
    extend Filter

    def self.filter(data : Context::DataType, args : Array(Context::DataType)? = nil) : Context::DataType
      if data.responds_to? :abs
        data.abs
      elsif data.is_a? String && (float = data.to_f32?)
        float.abs
      else
        data
      end
    end
  end

  class Append
    extend Filter

    def self.filter(data : Context::DataType, args : Array(Context::DataType)?) : Context::DataType
      raise FilterArgumentException.new "The append filter expects one argument" if !args || args.size != 1
      if args && (arg = args[0]) && arg.is_a? String && data.is_a? String
        data + arg
      else
        raise FilterArgumentException.new "The first argument of append filter should be a string" if args.size != 1
      end
    end
  end
end
