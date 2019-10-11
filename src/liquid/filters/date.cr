require "./base"

module Liquid::Filters
  # date
  # Converts a timestamp into another date format. The format for this syntax is the same as strftime.
  #
  # Input
  # {{ article.published_at | date: "%a, %b %d, %y" }}
  #
  # Output
  # Fri, Jul 17, 15
  #
  # Input
  # {{ article.published_at | date: "%Y" }}
  #
  # Output
  # 2015
  #
  # To get the current time, pass the special word "now" (or "today") to date:
  #
  # Input
  # This page was last updated at {{ "now" | date: "%Y-%m-%d %H:%M" }}.
  #
  # Output
  # This page was last updated at 2016-11-30 13:47.
  #
  # Note that the value will be the current time of when the page was last generated from the template, not when the page is presented to a user if caching or static site generation is involved.
  class Date
    extend Filter

    def self.filter(data : Any, arguments : Array(Any)?) : Any
      raise FilterArgumentException.new "date filter require an argument" unless arguments && arguments.size == 1

      format = if (arg = arguments.first.as_s?)
                 arg
               else
                 raise FilterArgumentException.new "First argument of date filter should be a string"
               end

      if (time = data.as_t?)
        Any.new time.to_s format
      elsif (d = data.as_s?) && d == "now"
        Any.new Time.utc.to_s format
      else
        data
      end
    end
  end

  FilterRegister.register "date", Date
end
