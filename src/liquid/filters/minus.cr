require "./base"

module Liquid::Filters
  class Minus
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      # raise error if user doesn't provide an argument to subtract by
      raise FilterArgumentException.new "minus filter expects one argument" unless args && args.first?

      # can only subtract numbers
      raise FilterArgumentException.new "minus filter expects a Number argument" unless args.first.raw.is_a?(Number)

      if (number = data.raw) && number.is_a?(Number) && (first = args.first?)
        result = self.subtract_by_any(data, first)
        if !result.nil?
          return Any.new result
        end
      end
      data
    end

    # convert left & right values to either an int or float and subtract them accordingly
    protected def self.subtract_by_any(l : Any, r : Any)
      if !l.raw.is_a?(Number) || !r.raw.is_a?(Number)
        nil
      end

      if l.as_i?.nil?
        left = l.as_f
      else
        left = l.as_i
      end

      if r.as_i?.nil?
        right = r.as_f
      else
        right = r.as_i
      end

      left - right
    end
  end

  FilterRegister.register "minus", Minus
end
