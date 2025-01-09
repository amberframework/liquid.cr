require "./drop"

module Liquid
  struct Any
    alias Type = Nil | Bool | Int32 | Int64 | Float32 | Float64 | String | Time | Array(Any) | Hash(String, Any) | Drop

    # Returns the raw underlying value.
    getter raw : Type

    def initialize
      @raw = nil
    end

    def initialize(@raw : Type)
    end

    def <<(value : Type) : Array(Any)
      init_raw_to_array_if_nil << Any.new(value)
    end

    def <<(value : Any) : Array(Any)
      init_raw_to_array_if_nil << value
    end

    # Assumes the underlying value is an `Array` or `Hash` and returns its size.
    # Raises if the underlying value is not an `Array` or `Hash`.
    def size : Int
      case object = @raw
      when Array
        object.size
      when Hash
        object.size
      else
        raise InvalidExpression.new("Expected Array or Hash for #size, not #{object.class}.")
      end
    end

    # Assumes the underlying value is an `Array` and returns the element
    # at the given index.
    # Raises if the underlying value is not an `Array`.
    def [](index : Int) : Any
      case object = @raw
      when Array
        object[index]
      else
        raise InvalidExpression.new("Expected Array for #[](index : Int), not #{object.class}.")
      end
    end

    # Assumes the underlying value is an `Array` and returns the element
    # at the given index, or `nil` if out of bounds.
    # Raises if the underlying value is not an `Array`.
    def []?(index : Int) : Any?
      case object = @raw
      when Array
        object[index]?
      else
        raise InvalidExpression.new("Expected Array for #[]?(index : Int), not #{object.class}.")
      end
    end

    # Assumes the underlying value is a `Hash` and returns the element
    # with the given key.
    # Raises if the underlying value is not a `Hash`.
    def [](key : String) : Any
      case object = @raw
      when Hash
        object[key]
      else
        raise InvalidExpression.new("Expected Hash for #[](key : String), not #{object.class}.")
      end
    end

    # Assumes the underlying value is a `Hash` and returns the element
    # with the given key, or `nil` if the key is not present.
    # Raises if the underlying value is not a `Hash`.
    def []?(key : String) : Any?
      case object = @raw
      when Hash
        object[key]?
      else
        raise InvalidExpression.new("Expected Hash for #[]?(key : String), not #{object.class}.")
      end
    end

    def []=(key : String | Symbol, value : Type) : Type
      init_raw_to_hash_if_nil[key.to_s] = Any.new(value)
      value
    end

    def []=(key : String | Symbol, value : Any) : Any
      init_raw_to_hash_if_nil[key.to_s] = value
    end

    private def init_raw_to_hash_if_nil : Hash(String, Any)
      if @raw.nil?
        @raw = Hash(String, Any).new
      else
        as_h
      end
    end

    private def init_raw_to_array_if_nil : Array(Any)
      if @raw.nil?
        @raw = Array(Any).new
      else
        as_a
      end
    end

    # Traverses the depth of a structure and returns the value.
    # Returns `nil` if not found.
    def dig?(index_or_key : String | Int, *subkeys) : Any?
      self[index_or_key]?.try &.dig?(*subkeys)
    end

    # :nodoc:
    def dig?(index_or_key : String | Int) : Any?
      case @raw
      when Hash, Array
        self[index_or_key]?
      else
        nil
      end
    end

    # Traverses the depth of a structure and returns the value, otherwise raises.
    def dig(index_or_key : String | Int, *subkeys) : Any
      self[index_or_key].dig(*subkeys)
    end

    # :nodoc:
    def dig(index_or_key : String | Int) : Any
      self[index_or_key]
    end

    # Checks that the underlying value is `Nil`, and returns `nil`.
    # Raises otherwise.
    def as_nil : Nil
      @raw.as(Nil)
    end

    # Checks that the underlying value is `Bool`, and returns its value.
    # Raises otherwise.
    def as_bool : Bool
      @raw.as(Bool)
    end

    # Checks that the underlying value is `Bool`, and returns its value.
    # Returns `nil` otherwise.
    def as_bool? : Bool?
      as_bool if @raw.is_a?(Bool)
    end

    # Checks that the underlying value is `Int`, and returns its value as an `Int32`.
    # Raises otherwise.
    def as_i : Int32
      @raw.as(Int).to_i
    end

    # Checks that the underlying value is `Int`, and returns its value as an `Int32`.
    # Returns `nil` otherwise.
    def as_i? : Int32?
      as_i if @raw.is_a?(Int)
    end

    # Checks that the underlying value is `Int`, and returns its value as an `Int64`.
    # Raises otherwise.
    def as_i64 : Int64
      @raw.as(Int).to_i64
    end

    # Checks that the underlying value is `Int`, and returns its value as an `Int64`.
    # Returns `nil` otherwise.
    def as_i64? : Int64?
      as_i64 if @raw.is_a?(Int64)
    end

    # Checks that the underlying value is `Float`, and returns its value as an `Float64`.
    # Raises otherwise.
    def as_f : Float64
      @raw.as(Float64)
    end

    # Checks that the underlying value is `Float`, and returns its value as an `Float64`.
    # Returns `nil` otherwise.
    def as_f? : Float64?
      @raw.as?(Float64)
    end

    # Checks that the underlying value is `Float`, and returns its value as an `Float32`.
    # Raises otherwise.
    def as_f32 : Float32
      @raw.as(Float).to_f32
    end

    # Checks that the underlying value is `Float`, and returns its value as an `Float32`.
    # Returns `nil` otherwise.
    def as_f32? : Float32?
      as_f32 if @raw.is_a?(Float)
    end

    # Checks that the underlying value is `String`, and returns its value.
    # Raises otherwise.
    def as_s : String
      @raw.as(String)
    end

    # Checks that the underlying value is `String`, and returns its value.
    # Returns `nil` otherwise.
    def as_s? : String?
      @raw.as?(String)
    end

    # Checks that the underlying value is `Time`, and returns its value.
    # Raises otherwise.
    def as_t : Time
      @raw.as(Time)
    end

    # Checks that the underlying value is `Time`, and returns its value.
    # Returns `nil` otherwise.
    def as_t? : Time?
      @raw.as?(Time)
    end

    # Checks that the underlying value is `Array`, and returns its value.
    # Raises otherwise.
    def as_a : Array(Any)
      @raw.as(Array)
    end

    # Checks that the underlying value is `Array`, and returns its value.
    # Returns `nil` otherwise.
    def as_a? : Array(Any)?
      as_a if @raw.is_a?(Array)
    end

    # Checks that the underlying value is `Hash`, and returns its value.
    # Raises otherwise.
    def as_h : Hash(String, Any)
      @raw.as(Hash)
    end

    # Checks that the underlying value is `Hash`, and returns its value.
    # Returns `nil` otherwise.
    def as_h? : Hash(String, Any)?
      as_h if @raw.is_a?(Hash)
    end

    def inspect(io : IO) : Nil
      @raw.inspect(io)
    end

    def -
      raw = @raw
      raise InvalidExpression.new("Can't apply '-' operator to #{raw.class.name}") unless raw.is_a?(Number)

      Any.new(-raw)
    end

    # Checks that the underlying value is a `Number`, and returns its value.
    # Raises otherwise.
    def as_number : Number
      as_number? || raise TypeCastError.new("Cast from String to Number+ failed")
    end

    # Checks that the underlying value is a `Number`, and returns its value.
    # Returns `nil` otherwise.
    def as_number?
      raw = @raw
      if raw.is_a?(Number)
        raw
      elsif raw.is_a?(String)
        raw.to_i? || raw.to_f? || nil
      elsif raw.responds_to?(:to_number)
        raw.to_number
      else
        nil
      end
    end

    # Checks that the underlying value is a `Number`, and returns its value.
    # Returns 0 otherwise.
    def as_number_or_zero : Number
      as_number? || 0
    end

    def to_s(io : IO) : Nil
      @raw.to_s(io)
    end

    # :nodoc:
    def pretty_print(pp)
      @raw.pretty_print(pp)
    end

    # Returns `true` if both `self` and *other*'s raw object are equal.
    def ==(other : Any)
      raw == other.raw
    end

    # Returns `true` if the raw object is equal to *other*.
    def ==(other)
      raw == other
    end

    def logical_and(other : Any) : Bool
      !!(@raw && other.raw)
    end

    def logical_or(other : Any) : Bool
      !!(@raw || other.raw)
    end

    def contains?(other : Any) : Bool
      raw = @raw
      return raw.includes?(other) if raw.is_a?(Array(Any))

      other_raw = other.raw
      return raw.includes?(other_raw) if raw.is_a?(String) && other_raw.is_a?(String)

      false
    end

    {% for operator in %w(< <= > >=) %}
    def {{ operator.id }}(other : Any) : Bool
      raw = @raw
      other_raw = other.raw
      if raw.is_a?(Number) && other_raw.is_a?(Number)
        raw {{ operator.id }} other_raw
      else
        raise InvalidExpression.new("Can't  use #{{{ operator }}} with #{raw.class.name} and #{other_raw.class.name}")
      end
    end
    {% end %}

    # See `Object#hash(hasher)`
    def_hash raw
  end
end
