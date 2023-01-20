require "./any"
require "./blank"

module Liquid
  class Context
    # Context error mode.
    enum ErrorMode
      # Raise exceptions on any error but `UndefinedVariable`, that can be accessed later by `Context#errors`.
      Strict
      # Like `Lax` mode, but the errors can be accessed later by `Context#errors`.
      Warn
      # Do the best to render something without raising any exceptions.
      Lax
    end

    @data : Hash(String, Any)

    # :nodoc:
    # These values are used/reused when calling filters in a expression using this context.
    protected getter filter_args = Array(Any).new
    # :nodoc:
    protected getter filter_options = Hash(String, Any).new(Any.new)

    property error_mode : ErrorMode
    # List of errors found when rendering using this context.
    getter errors = Array(LiquidException).new

    def initialize(@error_mode = :lax, @data = Hash(String, Any).new)
      add_builtins
    end

    delegate :strict?, to: @error_mode
    delegate :warn?, to: @error_mode
    delegate :lax?, to: @error_mode

    @[Deprecated("Use `initialize(ErrorMode)` instead.")]
    def initialize(strict : Bool)
      @data = Hash(String, Any).new
      @error_mode = strict ? ErrorMode::Strict : ErrorMode::Lax
      add_builtins
    end

    private def add_builtins
      self["empty"] = [] of Any
      self["blank"] = Blank.new
    end

    protected def reset_filter_context
      @filter_args.clear
      @filter_options.clear
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

    protected def add_error(error : LiquidException) : Any
      raise error if @error_mode.strict?

      @errors << error if @error_mode.warn?
      Any.new(nil)
    end

    protected def add_error(error : UndefinedVariable) : Any
      @errors << error if @error_mode.warn? || @error_mode.strict?
      Any.new(nil)
    end

    # Fetch a variable from context, add `UndefinedVariable` error if the variable isn't found and behave according the
    # error mode.
    def get(var : String) : Any
      value = @data[var]?
      return value if value

      add_error(UndefinedVariable.new(var))
    end

    # Alias for `#get`
    def [](var : String) : Any
      get(var)
    end

    # Fetch a variable from context and return nil if the variable isn't found.
    #
    # This doesn't trigger any exceptions or store any errors if the variable doesn't exists.
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
