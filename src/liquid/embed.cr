require "./context"

module Liquid
  macro embed(filename, io_name, *args)
    {% if args.size > 0 %}
      \{{run "liquid/process", {{filename}}, {{io_name.id.stringify}}, {{args[0].id.stringify}}}}
    {% else %}
      \{{run "liquid/process", {{filename}}, {{io_name.id.stringify}}}}
    {% end %}
  end
end
