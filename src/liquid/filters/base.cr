require "../context"

module Liquid::Filters::Filter
  abstract def filter(data : Any, arguments : Array(Any)?) : Any
end
