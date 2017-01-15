require "./base"

module Liquid::Filters
  class DividedBy
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      
      # raise error if user doesn't provide an argument to divided by
      raise FilterArgumentException.new "divided_by filter expects one argument" unless args && args.first?

      # raise error if we're trying to divide by zero
      raise FilterArgumentException.new "divided_by filter cannot divide by 0 or 0.0" unless args.first != 0 && args.first != 0.0

      if (raw = data.raw) && raw.is_a?(Number) && args && (first = args.first?) && first.raw.is_a?(Number)
        result = self.divide_by_any(data, first)
        if !result.nil?
          return Any.new result
        end
      end
      data
    end

    # convert left & right values to either an int or float and divide them accordingly
    protected def self.divide_by_any(l : Any, r : Any)
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

      left / right
    end
  end

  FilterRegister.register "divided_by", DividedBy
end