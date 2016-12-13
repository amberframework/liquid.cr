module Liquid
  class Context
    @inner = Hash(String, DataType).new

    def self.new(ctx : Context)
      ctx.dup
    end

    def set(key, value)
      @inner[key] = value
    end

    def get(key)
      @inner[key]
    end
    
    def [](key)
      get(key)
    end

    def delete(key)
      @inner.delete key
    end

    alias DataType = Nil | String | Int32 | Bool | Array(DataType) | Hash(DataType, DataType)
  end
end