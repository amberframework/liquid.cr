require "./base"

module Liquid::Filters
  # floor
  #
  # floors a string or float value and returns the value floor'd
  #
  # Input
  # {{ "1.34" | floor }}
  #
  # Output
  # 1.0
  class Floor
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      if (str_data = data.as_s?) && !str_data.to_f?.nil?
        Any.new str_data.to_f.floor
      elsif (fl_data = data.as_f?)
        Any.new fl_data.floor
      else
        data
      end
    end
  end

  FilterRegister.register "floor", Floor
end
