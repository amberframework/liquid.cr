require "./any"

module Liquid
  struct Context
    @inner : Hash(String, Any)
    property strict : Bool = false

    def initialize(@strict = false)
      @inner = Hash(String, Any).new
      self["empty"] = [] of Any
    end

    def parse_error(key, strict : Bool, message : String? = nil)
      message ||= "Parse error: \"#{key}\""
      if strict
        raise LiquidException.new(message)
      else
        nil
      end
    end

    def index_error(key, strict : Bool)
      if strict
        raise IndexError.new("Array index out of bounds: \"#{key}\"")
      else
        nil
      end
    end

    def key_missing(key, strict : Bool)
      if strict
        raise KeyError.new("Key does not exist in context: \"#{key}\"")
      else
        nil
      end
    end

    STRING_OR_INT_OR_VAR = /\[((#{STRING})|(#{INT})|(#{VAR}))\]/
    NEGATIVE_INT         = /^(\-?#{INT})$/
    NEGATIVE_VAR         = /^\-?(#{VAR})$/

    # key can include . (property/method access) and/or [] (array index)
    @[AlwaysInline]
    def get(key, strict : Bool = @strict)
      if key =~ /^(.*?)\?$/
        key = $1
        strict = false
      end

      return @inner[key] if @inner.has_key?(key)

      prefixes = [] of String
      if key =~ /^([-!]+)(.*?)$/
        prefixes = $1.split(//)
        key = $2
      end

      segments = key.split(".", remove_empty: false)

      # there should not be any blank segments (e.g. asdf..fdsa, .asdf, asdf.)
      return parse_error(key, strict) if segments.any?(&.blank?)

      # rejoin any segments that got broken in the middle of an array index
      segments.each_with_index do |segment, i|
        if segment.includes?("[") && !segment.includes?("]")
          # join until we find the closing bracket
          (i + 1...segments.size).each do |j|
            str = segments[j]
            segments[j] = ""
            segments[i] = "#{segments[i]}.#{str}"
            break if str.includes?("]") # found the closing bracket
          end
        end
      end

      # remove any segments that are now blank
      segments.reject!(&.blank?)

      ret : Any? = nil

      segments.each do |k|
        next unless k

        # ignore array index/hash key if present, first handle methods/properties
        bracket_index = k.index('[')
        name =
          if bracket_index && k.ends_with?(']')
            k[0...bracket_index]
          else
            k
          end

        if ret
          # handle a selection of convenience methods
          # wrap values in Any to make sure the return type is always the same
          case name
          when "present"
            if (array = ret.as_a?)
              ret = Any.new(array.size > 0)
            elsif (hash = ret.as_h?)
              ret = Any.new(hash.keys.size > 0)
            else
              ret = Any.new(ret.raw.to_s.size > 0)
            end
          when "blank"
            if (array = ret.as_a?)
              ret = Any.new(array.size == 0)
            elsif (hash = ret.as_h?)
              ret = Any.new(hash.keys.size == 0)
            else
              ret = Any.new(ret.raw.to_s.size == 0)
            end
          when "size"
            if (array = ret.as_a?)
              ret = Any.new(array.size)
            elsif (hash = ret.as_h?)
              ret = Any.new(hash.keys.size)
            elsif (str = ret.as_s?)
              ret = Any.new(str.size)
            else
              return parse_error(key, strict, "Parse error: Tried to call #size on something other than a String, Array or Hash (#{key} -> #{ret.inspect})")
            end
          else
            # if not a method, then it's a property (implemented as JSON hash member)
            if (hash = ret.as_h?)
              return key_missing(key, strict) unless hash.has_key?(k)

              ret = hash[k]
            else
              return parse_error(key, strict, "Parse error: Tried to access property of a non-hash object (#{key} -> #{ret.inspect})")
            end
          end
        else
          # first time through ret = nil, name should correspond to a top level key in @inner
          if @inner.has_key?(name)
            ret = @inner[name]
          else
            if strict
              return key_missing(key, strict)
            else
              # keep going, in case we're ultimately just doing a #blank check
              ret = Any.new(nil)
            end
          end
        end

        while k =~ STRING_OR_INT_OR_VAR
          index = $1
          # puts index
          if (index =~ NEGATIVE_INT) && (idx = $1.to_i?) && ret && (array = ret.as_a?)
            # array access via integer literal
            return index_error(key, strict) unless (-array.size..array.size).includes?(idx)

            ret = array[idx]
            k = k.sub("[#{index}]", "")
          elsif (match = index.match(GSTRING)) && ret && (hash = ret.as_h?)
            # hash access via string literal
            hashkey = match["str"]
            if hash.has_key?(hashkey)
              ret = hash[hashkey]
            else
              return key_missing(key, strict)
            end

            k = k.sub("[#{index}]", "")
          elsif (index =~ NEGATIVE_VAR) && (varname = $1) && ret && (array = ret.as_a?)
            # array access via integer variable
            invert = (index[0] == '-')
            if (realidx = self[varname]?.try(&.as_i?))
              realidx *= invert ? -1 : 1
              return index_error(key, strict) unless (-array.size..array.size).includes?(realidx)

              ret = array[realidx]
              k = k.sub("[#{index}]", "")
            else
              return key_missing(key, strict)
            end
          elsif (varname = index) && ret && (hash = ret.as_h?)
            # hash access via string variable
            if (realkey = self[varname]?.try(&.as_s?))
              return key_missing(key, strict) unless hash.has_key?(realkey)

              ret = hash[realkey]
              k = k.sub("[#{index}]", "")
            else
              return parse_error(key, strict, "#{key}: Could not resolve hash key `#{varname}` to String value")
            end
          else
            # hmm, we failed to match any known indexing scheme
            return parse_error(key, strict)
          end
        end
      end

      # apply prefixes in reverse order
      prefixes.reverse.each do |prefix|
        case prefix
        when "-"
          if ret && ((num = ret.as_i?) || (num = ret.as_f?))
            ret = Any.new(-1 * num)
          else
            return parse_error(key, true, "Parse error: Couldn't interpret #{ret.inspect} as numeric value (#{key})")
          end
        when "!"
          # booleans are tricky... first, treat nil as false
          # next, check to see whether it can be interpret as bool (check for nil
          # specifically, to avoid returning parse error on false value)
          if ret.nil? || ret.raw.nil?
            ret = Any.new(true)
          elsif !(bool = ret.as_bool?).nil?
            ret = Any.new(!bool)
          else
            return parse_error(key, true, "Parse error: Couldn't interpret #{ret.inspect} as boolean value (#{key})")
          end
        else
          return parse_error(key, true, "Parse error: Unknown prefix operator #{prefix}")
        end
      end

      # unwrap if it's just a nil inside a Any (note: Expression sometimes re-wraps it)
      ret = nil if ret && ret.raw.nil?

      ret
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
