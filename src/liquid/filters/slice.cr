require "./base"

module Liquid::Filters
  class StrSlice
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      # raise error if user doesn't provide an argument to divided by
      raise FilterArgumentException.new "slice filter expects at least one argument" unless args && args.first?

      # raise error if user doesn't provide an argument to divided by
      raise FilterArgumentException.new "slice filter expects argument to be an integer" unless args.first.raw.is_a?(Int)

      if (str = data.as_s?) && (first = args.first.as_i?)
        second = -1

        # if we pass another argument and it's an integer then override default range
        if args.size > 1 && args.last(1)[0]? && args.last(1)[0].as_i?
          second = args.last(1)[0].as_i
        end

        begin
          str = str[first..second]
          Any.new str
        rescue
          data
        end
      else
        data
      end
    end
  end

  FilterRegister.register "slice", StrSlice
end
