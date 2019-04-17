require "json"
require "./any"

module Liquid
  struct Context
    JSON.mapping(
      inner: Hash(String, JSON::Any),
      strict: {type: Bool, default: false}
    )

    property strict : Bool = false

    def initialize(@strict = false)
      @inner = Hash(String, JSON::Any).new
    end

    def [](key : String)
      if (ret = self[key]?)
        ret
      else
        raise KeyError.new("Missing context key: \"#{key}\"")
      end
    end

    # key can include . (property/method access) and/or [] (array index)
    def []?(key : String) : JSON::Any?
      return @inner[key] if @inner[key]?

      prefixes = [] of String
      if key =~ /^([-!]+)(.*?)$/
        prefixes = $1.split(//)
        key = $2
      end

      segments = key.split(".", remove_empty: false)

      # there should not be any blank segments (e.g. asdf..fdsa, .asdf, asdf.)
      return nil if segments.any?(&.blank?)

      # rejoin any segments that got broken in the middle of an array index
      segments.each_with_index do |segment, i|
        if segment.includes?("[") && !segment.includes?("]")
          # join until we find the closing bracket
          (i + 1...segments.size).each do |j|
            str = segments[j]
            segments[j] = ""
            segments[i] = [segments[i], str].join(".")
            break if str.includes?("]") # found the closing bracket
          end
        end
      end

      # remove any segments that are now blank
      segments.reject!(&.blank?)

      ret : JSON::Any? = nil

      segments.each do |k|
        next unless k

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

        while k =~ /\[((#{STRING})|(#{INT})|(#{VAR}))\]/
          index = $1
          # puts index
          if (index =~ /^(\-?#{INT})$/) && (idx = $1.to_i?) && ret && (array = ret.as_a?)
            # array access via integer literal
            return nil unless array[idx]?

            ret = array[idx]
            k = k.sub("[#{index}]", "")
          elsif (match = index.match(GSTRING)) && ret && (hash = ret.as_h?)
            # hash access via string literal
            hashkey = match["str"]
            return nil unless hash[hashkey]?

            ret = hash[hashkey]
            k = k.sub("[#{index}]", "")
          elsif (index =~ /^\-?(#{VAR})$/) && (varname = $1) && ret && (array = ret.as_a?)
            # array access via integer variable
            invert = (index[0] == '-')
            if (realidx = self[varname]?.try(&.as_i?)) && (val = array[(invert ? -1 : 1) * realidx]?)
              ret = val
              k = k.sub("[#{index}]", "")
            else
              return nil
            end
          elsif (varname = index) && ret && (hash = ret.as_h?)
            # hash access via string variable
            if (realkey = self[varname]?.try(&.as_s?)) && (val = hash[realkey]?)
              ret = val
              k = k.sub("[#{index}]", "")
            else
              return nil
            end
          else
            # hmm, we failed to match any known indexing scheme
            return nil
          end
        end
      end

      # apply prefixes in reverse order
      prefixes.reverse.each do |prefix|
        case prefix
        when "-"
          if (num = ret.as_i?) || (num = ret.as_f?)
            ret = JSON::Any.new(-1 * num)
          else
            raise "Couldn't interpret #{ret} as numeric value (#{key})"
          end
        when "!"
          if !(bool = ret.as_bool?).nil? # booleans are tricky, check for nil specifically
            ret = JSON::Any.new(!bool)
          else
            raise "Couldn't interpret #{ret} as boolean value (#{key})"
          end
        else
          raise "Unknown prefix operator #{prefix}"
        end
      end if ret

      ret
    end

    @[AlwaysInline]
    def []=(key, value)
      @inner[key] = Any.from_json value.to_json
    end

    # alias for []?(key)
    @[AlwaysInline]
    def get(key)
      # optional if ? is appended to key; otherwise, follow @strict setting
      if key =~ /^(.*?)\?$/
        self[$1]?
      else
        @strict ? self[key] : self[key]?
      end
    end

    # alias for []=(key, val)
    @[AlwaysInline]
    def set(key, val)
      self[key] = val
    end
  end
end
