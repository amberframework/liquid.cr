require "json"

struct JSON::Any
  def initialize(raw : Int32)
    @raw = raw.to_i64
  end

  def initialize(raw : Float32)
    @raw = raw.to_f64
  end

  def initialize(raw : Time)
    @raw = raw.to_json
  end

  def as_t?
    begin
      as_t
    rescue
      nil
    end
  end

  def as_t
    Time.from_json(@raw.as(String))
  end
end

module Liquid
  alias Any = JSON::Any

  struct AnyHash
    getter raw

    def initialize
      @raw = Hash(String, JSON::Type).new
    end

    {% for x in %w(String Int64 Bool Float64) %}
    def []=(key : String, value : {{x.id}})
      @raw[key] = value.as(JSON::Type)
    end
    {% end %}

    def []=(key : String, value : Array)
    end

    def []=(key : String, value : Hash)
    end
  end
end
