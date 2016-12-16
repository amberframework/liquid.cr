require "./base"

module Liquid::Filters

  #   newline_to_br
  #  
  # Replaces every newline (\n) with an HTML line break (<br>).
  #  
  # Input
  # {% capture string_with_newlines %}
  # Hello
  # there
  # {% endcapture %}
  #  
  # {{ string_with_newlines | newline_to_br }}
  #  
  # Output
  # <br />
  # Hello<br />
  # there<br />
  class NewLineToBr
    extend Filter

    def self.filter(data : Context::DataType, args : Array(Context::DataType)? = nil) : Context::DataType
      if data.responds_to? :to_s
        data.to_s.gsub /\n/, "<br />"
      else
        data
      end
    end
  end

  FilterRegister.register "newline_to_br", NewLineToBr
  
end
