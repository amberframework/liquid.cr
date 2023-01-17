require "./base"
require "../filters"

module Liquid::Filters
  class Replace
    extend Filter

    def self.filter(data : Any, args : Array(Any), options : Hash(String, Any)) : Any
      if (first = args.first?) && (second = args[1]?) &&
         (from = first.as_s?) && (to = second.as_s?) && (d = data.as_s?)
        Any.new d.gsub from, to
      else
        # TODO raise invalid filter call ?
        data
      end
    end
  end

  FilterRegister.register("replace", Replace)
end
