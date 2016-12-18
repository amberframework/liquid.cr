module Liquid
  macro embed(filename, io_name)
    \{{run "liquid/process", {{filename}}, {{io_name.id.stringify}}}}
  end
end
