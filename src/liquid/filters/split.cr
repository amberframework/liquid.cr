require "./base"

module Liquid::Filters

  #   split
  #  
  # Divides an input string into an array using the argument as a separator. split is commonly used to convert comma-separated items from a string to an array.
  #  
  # Input
  # {% assign beatles = "John, Paul, George, Ringo" | split: ", " %}
  #  
  # {% for member in beatles %}
  #   {{ member }}
  # {% endfor %}
  #  
  # Output
  #   John
  #  
  #   Paul
  #  
  #   George
  #  
  #   Ringo
  class Split
    extend Filter

    def self.filter(data : Context::DataType, args : Array(Context::DataType)? = nil) : Context::DataType 
      raise FilterArgumentException.new "split filter expects one string argument" unless args && args.first?.is_a? String

      arg = args.first
      
      if data.responds_to? :split && (arg.is_a? String || arg.is_a? Regex)
        arr = Array(Context::DataType).new
        data.split(arg).each {|str| arr << str }
        arr
      else
        data
      end

    end
    
  end

  FilterRegister.register "split", Split
  
end
