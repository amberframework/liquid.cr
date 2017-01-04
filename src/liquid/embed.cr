require "./context"

module Liquid
  macro embed(filename, io_name, *args)
    \{{run "./liquid/process", {{filename}}, {{io_name.id.stringify}}}}
  end


  macro file(filename, io_name = "__liquid_io__", *args)
    def to_s({{io_name.id}})
      Liquid.embed({{filename}}, {{io_name}}, {{*args}})
    end
  end

  macro render(filename, *args)
    String.build do |__kilt_io__|
      Liquid.embed({{filename}}, "__kilt_io__", {{*args}})
    end
  end

end
