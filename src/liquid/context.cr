require "./any"

module Liquid
  struct Context
    @inner = Hash(String, JSON::Any).new

    def [](key : String)
      if !@inner[key]? && key.includes? '.'
        splitted = key.split '.'
        res = @inner[splitted.first]
        splitted[1..-1].each do |k|
          res = res[k]
        end
        res
      else
        @inner[key]
      end
    end

    def []?(key : String)
      if !@inner[key]? && key.includes? '.'
        splitted = key.split '.'
        res = @inner[splitted.first]?
        splitted[1..-1].each do |k|
          res = res[k]? if res
        end
        res
      else
        @inner[key]?
      end
    end

    @[AlwaysInline]
    def []=(key, value)
      @inner[key] = Any.from_json value.to_json
    end

    # alias for []?(key)
    @[AlwaysInline]
    def get(key)
      self[key]?
    end

    # alias for []=(key, val)
    @[AlwaysInline]
    def set(key, val)
      self[key] = val
    end
  end
end
