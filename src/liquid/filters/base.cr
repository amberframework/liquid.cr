require "../context"

module Liquid::Filters::Filter
  abstract def filter(data : Any, args : Array(Any)?) : Any
end
