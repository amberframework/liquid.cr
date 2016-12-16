require "./base"

module Liquid::Filters

  # join
  #  
  # Combines the items in an array into a single string using the argument as a separator.
  #  
  # Input
  # {% assign beatles = "John, Paul, George, Ringo" | split: ", " %}
  #  
  # {{ beatles | join: " and " }}
  #  
  # Output
  # John and Paul and George and Ringo
  class Join
    extend Filter

    def self.filter(data : Context::DataType, args : Array(Context::DataType)? = nil) : Context::DataType
      raise FilterArgumentException.new "join filter expects one string argument" unless args && args.first?.is_a? String

      if data.responds_to? :join
        data.join args.first
      else
        data
      end
      
    end
    
  end

  FilterRegister.register "join", Join
  
end
