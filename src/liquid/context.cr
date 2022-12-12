require "./any"

module Liquid
  class Context
    enum ErrorMode
      Strict
      Warn
      Lax
    end

    @data = Hash(String, Any).new
    property error_mode : ErrorMode
    getter errors = Array(String).new

    def initialize(@error_mode = :lax)
      add_builtins
    end

    delegate :strict?, to: @error_mode
    delegate :warn?, to: @error_mode
    delegate :lax?, to: @error_mode

    @[Deprecated("Use `initialize(ErrorMode)` instead.")]
    def initialize(strict : Bool)
      @error_mode = strict ? ErrorMode::Strict : ErrorMode::Lax
      add_builtins
    end

    private def add_builtins
      self["empty"] = [] of Any
    end

    @[Deprecated("Use `#error_mode` instead.")]
    def strict : Bool
      @error_mode.strict?
    end

    @[Deprecated("Use `#error_mode=` instead.")]
    def strict=(value : Bool) : Bool
      @error_mode = value ? ErrorMode::Strict : ErrorMode::Lax
      value
    end

    def get(var : String) : Any
      value = @data[var]?
      return value if value

      if !@error_mode.lax?
        error_message = "Variable \"#{var}\" not found."
        raise InvalidExpression.new(error_message) if @error_mode.strict?

        @errors << error_message if @error_mode.warn?
      end

      Any.new(nil)
    end

    def [](var : String) : Any
      get(var)
    end

    def []?(var : String) : Any?
      @data[var]?
    end

    def set(var : String, value : Any) : Any
      @data[var] = value
    end

    def set(var : String, value : Any::Type) : Any
      set(var, Any.new(value))
    end

    def []=(var, value : Any) : Any
      set(var, value)
    end

    def []=(var, value : Any::Type) : Any
      set(var, value)
    end

    @[Deprecated("Use `#[]` or `#[]?` instead.")]
    def get(var, strict : Bool)
      strict ? self[var] : self[var]?
    end

    @[Deprecated("Use `#set` instead.")]
    def []=(var : String, val : Array(String))
      self[var] = val.map { |e| Any.new(e) }
    end

    @[Deprecated("Use `#set` instead.")]
    def []=(var : String, val : Hash(String, String))
      hash = Hash(String, Any).new
      val.each { |k, v| hash[k] = Any.new(v) }
      self[var] = hash
    end

    def to_s(io : IO)
      @data.to_s(io)
    end
  end
end
