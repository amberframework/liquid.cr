require "./context"
require "json"

module Liquid
  macro embed(filename, io_name, *args)
    \{{run "liquid/process", {{filename}}, {{io_name.id.stringify}} }}
  end
end
