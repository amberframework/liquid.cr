require "json"
require "./any"

module Liquid
  struct Context
    JSON.mapping(
      inner: Hash(String, JSON::Any)
    )

    def initialize
      @inner = Hash(String, JSON::Any).new
    end

    def [](key : String)
      if (ret = self[key]?)
        ret
      else
        raise IndexError.new
      end
    end

    # key can include . (property/method access) and/or [] (array index)
    def []?(key : String) : JSON::Any?
      return @inner[key] if @inner[key]?

      # there should not be any nil segments (e.g. asdf..fdsa, .asdf, asdf.)
      segments = key.split "."
      return nil if segments.any?(&.nil?)

      ret : JSON::Any? = nil

      segments.each do |k|
        # ignore array index/hash key if present, first handle methods/properties
        if k =~ /^(.*?)(?:\[.*?\])*$/
          name = $1
          if ret
            case name
            when "size"
              # need to wrap values in JSON::Any. little weird, but necessary to make sure the return type is always the same
              if (array = ret.as_a?)
                ret = JSON::Any.new(array.size)
              elsif (str = ret.as_s?)
                ret = JSON::Any.new(str.size)
              end
            else
              # if not a method, then it's a property
              if (hash = ret.as_h?) && hash[k]?
                ret = hash[k]
              else
                # could not find property
                return nil
              end
            end
          else
            # first time through ret = nil, name should correspond to a top level key in @inner
            ret = @inner[name]?
            return nil unless ret
          end
        end

        while k =~ /\[(.*?)\]/
          if ($1 =~ /^([-\d]+)$/) && (idx = $1.to_i?) && ret && (array = ret.as_a?)
            return nil unless array[idx]?

            ret = array[idx]
            k = k.sub(/\[#{idx}\]/, "")
          elsif (hashkey = $1)
            # TODO: Try to handle hash keys
            return nil

            # TODO: Need to strip off quote characters on hashkey
            return nil unless ret && (hash = ret.as_h?) && hash[hashkey]?
            ret = hash[hashkey]
            k = k.sub(/\[#{hashkey}\]/, "")
          end
        end
      end

      ret
    end

    @[AlwaysInline]
    def []=(key, value)
      @inner[key] = Any.from_json value.to_json
    end

    # alias for []?(key)
    @[AlwaysInline]
    def get(key)
      self[key]?
    end

    # alias for []=(key, val)
    @[AlwaysInline]
    def set(key, val)
      self[key] = val
    end
  end
end
