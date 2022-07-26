require "./any"
require "./stack_machine"

module Liquid
  struct Context
    @inner : Hash(String, Any)

    property strict : Bool

    def initialize(@strict = false)
      @inner = Hash(String, Any).new
      self["empty"] = [] of Any
    end

    def get(expr, strict : Bool = @strict) : Any?
      StackMachine.new(expr).evaluate(@inner)
    rescue e : Exception | KeyError
      raise e if strict

      nil
    end

    def [](key : String) : Any
      get(key, strict: true).not_nil!
    end

    def []?(key : String) : Any?
      get(key, strict: false)
    end

    @[AlwaysInline]
    def []=(key, value : Any)
      @inner[key] = value
    end

    @[AlwaysInline]
    def []=(key, value : Any::Type)
      @inner[key] = Any.new(value)
    end

    @[Deprecated]
    def []=(key : String, val : Array(String))
      self[key] = val.map { |e| Any.new(e) }
    end

    @[Deprecated]
    def []=(key : String, val : Hash(String, String))
      hash = Hash(String, Any).new
      val.each { |k, v| hash[k] = Any.new(v) }
      self[key] = hash
    end

    # alias for []=(key, val)
    @[AlwaysInline]
    def set(key : String, val)
      self[key] = val
    end
  end
end
