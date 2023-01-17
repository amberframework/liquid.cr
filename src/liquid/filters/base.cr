require "../context"

module Liquid::Filters::Filter
  abstract def filter(data : Any, args : Array(Any), options : Hash(String, Any)) : Any

  # :nodoc:
  # FIXME: This is meant to be used just in test code to reduce the boiler plate. All tests that use this call can be
  #        translated into normal template tests.
  def filter(data : Any, args : Array(Any)? = nil) : Any
    args ||= Array(Any).new
    options = Hash(String, Any).new(Any.new)
    filter(data, args, options)
  end
end
