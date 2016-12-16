require "./any"

module Liquid

  alias Type = Nil | String | Float32 | Float64 | Int32 | Bool | Time | Array(Type) | Hash(String, Type)

  class Context < Hash(String, Any)

    def set(key, val : Any)
      self[key] = val
    end

    def set(key, val : Type)
      self[key] = Any.new val
    end

    def get(key)
      self[key]?
    end

    def set(key, val : Array)
      self[key] = Any.new val
    end

    def dup
      ctx = Context.new()
      each do |key, value|
        ctx[key] = value
      end
      ctx
    end

  end

end
