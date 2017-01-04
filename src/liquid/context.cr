require "./any"

module Liquid
  alias Type = Nil | String | Float32 | Float64 | Int32 | Bool | Time | Array(Type) | Hash(String, Type)

  class Context < Hash(String, Any)
    def set(key, val : Any)
      self[key] = val
    end

    def set(key, val : Nil | String | Float32 | Float64 | Int32 | Bool | Time)
      self[key] = Any.new val
    end

    def [](key)
      if r = get key
        r
      else
        raise "Unable to find #{key} key"
      end
    end

    def get(key)
      if simple = self.fetch(key, nil)
        simple
      else
        regexp = /^(#{key}\.(\w+))/
        hash = Hash(String, Type).new
        self.keys.each do |k|
          if match = k.match regexp
            hash[match[2]] = self.get(match[1]).not_nil!.raw
          end
        end
        if !hash.empty?
          Any.new hash
        else
          nil
        end
      end
    end

    def set(key, val : Array)
      self[key] = Any.new val
    end

    def set(key, val : Hash)
      val.each do |k, v|
        self.set "#{key}.#{k}", v
      end
    end

    def dup
      ctx = Context.new
      each do |key, value|
        ctx[key] = value
      end
      ctx
    end
  end
end
