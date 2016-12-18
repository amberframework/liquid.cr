struct Liquid::Any
  include Enumerable(self)

  # Returns the raw underlying value, a `Liquid::Type`.
  getter raw : Liquid::Type

  # Creates a `Liquid::Any` that wraps the given `Liquid::Type`.
  def initialize(@raw : Liquid::Type)
  end

  def initialize(raw : Array)
    @raw = Array(Liquid::Type).new
    raw.each { |e| @raw.as(Array(Liquid::Type)) << e.as(Liquid::Type) }
  end

  def initialize(raw : Hash)
    @raw = Hash(String, Liquid::Type).new
    raw.each { |k, v| @raw.as(Hash(String, Liquid::Type))[k] = v }
  end

  # Assumes the underlying value is an `Array` or `Hash` and returns
  # its size.
  # Raises if the underlying value is not an `Array` or `Hash`.
  def size : Int
    case object = @raw
    when Array
      object.size
    when Hash
      object.size
    else
      raise "expected Array or Hash for #size, not #{object.class}"
    end
  end

  # Assumes the underlying value is an Array and returns the element
  # at the given index.
  # Raises if the underlying value is not an Array.
  def [](index : Int) : Liquid::Any
    case object = @raw
    when Array
      Any.new object[index]
    else
      raise "expected Array for #[](index : Int), not #{object.class}"
    end
  end

  # Assumes the underlying value is an Array and returns the element
  # at the given index, or nil if out of bounds.
  # Raises if the underlying value is not an Array.
  def []?(index : Int) : Liquid::Any?
    case object = @raw
    when Array
      value = object[index]?
      value.nil? ? nil : Any.new(value)
    else
      raise "expected Array for #[]?(index : Int), not #{object.class}"
    end
  end

  # Assumes the underlying value is a Hash and returns the element
  # with the given key.
  # Raises if the underlying value is not a Hash.
  def [](key : String) : Liquid::Any
    case object = @raw
    when Hash
      Any.new object[key]
    else
      raise "expected Hash for #[](key : String), not #{object.class}"
    end
  end

  # Assumes the underlying value is a Hash and returns the element
  # with the given key, or nil if the key is not present.
  # Raises if the underlying value is not a Hash.
  def []?(key : String) : Liquid::Any?
    case object = @raw
    when Hash
      value = object[key]?
      value.nil? ? nil : Any.new(value)
    else
      raise "expected Hash for #[]?(key : String), not #{object.class}"
    end
  end

  # Assumes the underlying value is an `Array` or `Hash` and yields each
  # of the elements or key/values, always as `Liquid::Any`.
  # Raises if the underlying value is not an `Array` or `Hash`.
  def each
    case object = @raw
    when Array
      object.each do |elem|
        yield Any.new(elem), Any.new(nil)
      end
    when Hash
      object.each do |key, value|
        yield Any.new(key), Any.new(value)
      end
    else
      raise "expected Array or Hash for #each, not #{object.class}"
    end
  end

  # Checks that the underlying value is `Nil`, and returns `nil`. Raises otherwise.
  def as_nil : Nil
    @raw.as(Nil)
  end

  # Checks that the underlying value is `Bool`, and returns its value. Raises otherwise.
  def as_bool : Bool
    @raw.as(Bool)
  end

  # Checks that the underlying value is `Bool`, and returns its value. Returns nil otherwise.
  def as_bool? : (Bool | Nil)
    as_bool if @raw.is_a?(Bool)
  end

  # Checks that the underlying value is `Int`, and returns its value as an `Int32`. Raises otherwise.
  def as_i : Int32
    @raw.as(Int).to_i
  end

  # Checks that the underlying value is `Int`, and returns its value as an `Int32`. Returns nil otherwise.
  def as_i? : (Int32 | Nil)
    as_i if @raw.is_a?(Int)
  end

  # Checks that the underlying value is `Int`, and returns its value as an `Int64`. Raises otherwise.
  def as_i64 : Int64
    @raw.as(Int).to_i64
  end

  # Checks that the underlying value is `Int`, and returns its value as an `Int64`. Returns nil otherwise.
  def as_i64? : (Int64 | Nil)
    as_i64 if @raw.is_a?(Int64)
  end

  # Checks that the underlying value is `Float`, and returns its value as an `Float64`. Raises otherwise.
  def as_f : Float64
    @raw.as(Float).to_f
  end

  # Checks that the underlying value is `Float`, and returns its value as an `Float64`. Returns nil otherwise.
  def as_f? : (Float64 | Nil)
    as_f if @raw.is_a?(Float64)
  end

  # Checks that the underlying value is `Float`, and returns its value as an `Float32`. Raises otherwise.
  def as_f32 : Float32
    @raw.as(Float).to_f32
  end

  # Checks that the underlying value is `Float`, and returns its value as an `Float32`. Returns nil otherwise.
  def as_f32? : (Float32 | Nil)
    as_f32 if (@raw.is_a?(Float32) || @raw.is_a?(Float64))
  end

  # Checks that the underlying value is `String`, and returns its value. Raises otherwise.
  def as_s : String
    @raw.as(String)
  end

  # Checks that the underlying value is `String`, and returns its value. Returns nil otherwise.
  def as_s? : (String | Nil)
    as_s if @raw.is_a?(String)
  end

  # Checks that the underlying value is `Array`, and returns its value. Raises otherwise.
  def as_a : Array(Type)
    @raw.as(Array)
  end

  # Checks that the underlying value is `Array`, and returns its value. Returns nil otherwise.
  def as_a? : (Array(Type) | Nil)
    as_a if @raw.is_a?(Array(Type))
  end

  # Checks that the underlying value is `Hash`, and returns its value. Raises otherwise.
  def as_h : Hash(String, Type)
    @raw.as(Hash)
  end

  # Checks that the underlying value is `Hash`, and returns its value. Returns nil otherwise.
  def as_h? : (Hash(String, Type) | Nil)
    as_h if @raw.is_a?(Hash(String, Type))
  end

  # Checks that the underlying value is `Time`, and returns its value. Raises otherwise
  def as_t : Time
    @raw.as(Time)
  end

  # Checks that the underlying value is `Time`, and returns its value. Returns nil otherwise.
  def as_t? : (Time | Nil)
    as_t if @raw.is_a?(Time)
  end

  # :nodoc:
  def inspect(io)
    @raw.inspect(io)
  end

  # :nodoc:
  def to_s(io)
    @raw.to_s(io)
  end

  # :nodoc:
  def pretty_print(pp)
    @raw.pretty_print(pp)
  end

  macro def_cmp(op)
    def {{op.id}}(other : Liquid::Any)
      return false if !raw.responds_to? :{{op.id}}
      case raw.class
      when other.raw.class
        raw {{op.id}} other.raw
      else
        false
      end
    end
  end

  {% for op in [:!=, :<=, :>=, :<, :>] %}
    def_cmp {{op}}
  {% end %}

  # Returns true if both `self` and *other*'s raw object are equal.
  def ==(other : Liquid::Any)
    raw == other.raw
  end

  # Returns true if the raw object is equal to *other*.
  def ==(other)
    raw == other
  end

  # :nodoc:
  def hash
    raw.hash
  end

  # :nodoc:
  def to_json(io)
    raw.to_json(io)
  end
end

class Object
  def ===(other : Liquid::Any)
    self === other.raw
  end
end

class Regex
  def ===(other : Liquid::Any)
    value = self === other.raw
    $~ = $~
    value
  end
end
