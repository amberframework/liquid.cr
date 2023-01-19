require "./base"

module Liquid::Filters
  class First
    extend Filter

    def self.filter(data : Any, args : Array(Any), options : Hash(String, Any)) : Any
      raw_data = data.raw
      value = if raw_data.is_a?(Hash)
                tuple = raw_data.first?
                Any{*tuple} if tuple
              elsif raw_data.responds_to?(:first?)
                raw_data.first?
              else
                Any.new(nil)
              end
      value.is_a?(Any) ? value : Any.new(value)
    end
  end

  FilterRegister.register "first", First
end
