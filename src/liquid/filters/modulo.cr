require "./base"

module Liquid::Filters
  class Modulo
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      # raise error if user doesn't provide an argument to divide by
      raise FilterArgumentException.new "modulo filter expects one argument" unless args && args.first?

      # can only subtract numbers
      raise FilterArgumentException.new "modulo filter expects a Number argument" unless args.first.raw.is_a?(Number)

      # raise error if we're trying to divide by zero
      raise FilterArgumentException.new "modulo filter cannot divide by 0 or 0.0" unless args.first != 0 && args.first != 0.0

      if (number = data.raw) && number.is_a?(Number) && (first = args.first?)
        result = self.divide_by_any(data, first)
        if !result.nil?
          return Any.new result
        end
      end
      data
    end

    # convert left & right values to either an int or float and get modulo
    protected def self.divide_by_any(l : Any, r : Any)
      # crystal can't divide an int by a float so we have to exit here
      if l.raw.is_a?(Int) && !r.raw.is_a?(Int)
        return nil
      end

      # the way crystal's divmod works with int's' is it doesn't like accept union types so if
      # we're divmodding an int we need to explicitly pass an int value
      if l.raw.is_a?(Int)
        left = l.as_i
        right = r.as_i
        _, modulo = left.divmod(right)
      else
        left = l.as_f
        if r.raw.is_a?(Int)
          right = r.as_i
        else
          right = r.as_f
        end
        _, modulo = left.divmod(right)
      end

      modulo
    end
  end

  FilterRegister.register "modulo", Modulo
end
