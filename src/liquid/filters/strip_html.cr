require "./base"

module Liquid::Filters
  #   strip_html
  #
  # Removes any HTML tags from a string.
  #
  # Input
  # {% capture string_with_html %}
  # Have <em>you</em> read <strong>Ulysses</strong>?
  # {% endcapture %}
  #
  # {{ string_with_html | strip_html }}
  #
  # Output
  # Have you read Ulysses?
  class StripHtml
    extend Filter

    def self.filter(data : Any, args : Array(Any), options : Hash(String, Any)?) : Any
      if data.raw.responds_to? :to_s
        Any.new data.raw.to_s.gsub(/<script.*?<\/script>/m, "").gsub(/<!--.*?-->/m, "").gsub(/<style.*?<\/style>/m, "").gsub(/<.*?>/m, "")
      else
        data
      end
    end
  end

  FilterRegister.register "strip_html", StripHtml
end
