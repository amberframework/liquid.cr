require "./base"
require "../filters"

module Liquid::Filters
  class ReplaceFirst
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      if args && (first = args.first?) && (second = args[1]?) &&
         (from = first.as_s?) && (to = second.as_s?) && (d = data.as_s?)
        Any.new d.sub from, to
      else
        # TODO raise invalid filter call ?
        data
      end
    end
  end

  FilterRegister.register("replace_first", ReplaceFirst)
end
