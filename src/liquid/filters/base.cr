require "../context"

module Liquid::Filters::Filter
  abstract def filter(data : Context::DataType, arguments : Array(Context::DataType)?) : DataType
end
