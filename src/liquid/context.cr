module Liquid
  class Context
    @inner = Hash(String, DataType).new

    def self.new(ctx : Context)
      ctx.dup
    end

    def set(key, value : DataType)
      @inner[key] = value
    end

    def set(key, value : Array)
      @inner[key] = value.map { |e| e.as(DataType) }
    end

    def get(key) : DataType
      @inner[key]?
    end

    def [](key)
      get(key)
    end

    def delete(key)
      @inner.delete key
    end

    alias DataType = Nil | String | Float32 | Float64 | Int32 | Bool | Time | Array(DataType) | Hash(DataType, DataType)
  end
end
