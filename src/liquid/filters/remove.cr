require "./base"

module Liquid::Filters
  class Remove
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      # raise error if user doesn't provide an argument to divided by
      raise FilterArgumentException.new "remove filter expects one argument" unless args && args.first?

      if (raw = data.raw) && raw.is_a? String && args && (first = args.first?) && first.raw.is_a? String
        str = data.as_s
        Any.new str.gsub(first.as_s, nil)
      else
        data
      end
    end
  end

  FilterRegister.register "remove", Remove
end
