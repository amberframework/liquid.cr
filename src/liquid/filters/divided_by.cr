require "./base"

module Liquid::Filters
  class DividedBy
    extend Filter

    def self.filter(data : Any, args : Array(Any), options : Hash(String, Any)) : Any
      raise FilterArgumentException.new("divided_by filter expects one argument.") if args.size != 1

      lvalue = data.as_number_or_zero
      rvalue = args.first.as_number_or_zero

      raise FilterArgumentException.new("divided_by filter cannot divide by 0 or 0.0.") if rvalue.zero?
      return Any.new(lvalue // rvalue) if rvalue.is_a?(Int) && lvalue.is_a?(Int)

      Any.new(lvalue / rvalue)
    end
  end

  FilterRegister.register "divided_by", DividedBy
end
