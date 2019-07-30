require "./base"

module Liquid::Filters
  class Round
    extend Filter

    def self.filter(data : Any, args : Array(Any)? = nil) : Any
      if (raw = data.raw) && raw.is_a?(Float)
        if args && (first = args.first?) && first.raw.is_a?(Number)
          Any.new self.round_to(raw, first)
        else
          Any.new raw.round
        end
      else
        data
      end
    end

    def self.round_to(num, round_to)
      if round_to.raw.is_a?(Int)
        round_to = round_to.as_i
      else
        round_to = round_to.as_f
      end

      num.round(round_to)
    end
  end

  FilterRegister.register "round", Round
end
