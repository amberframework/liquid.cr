require "./drop"

module Liquid
  class ForLoop < Drop
    @collection : Array(Any) | Hash(String, Any) | Range(Int32, Int32)
    getter parentloop : ForLoop?

    def initialize(@collection, @parentloop)
      @i = 0
    end

    @[Ignore]
    def each(&)
      collection = @collection
      if collection.is_a?(Array) || collection.is_a?(Range)
        collection.each do |val|
          yield(val)
          @i += 1
        end
      else
        collection.each do |key, val|
          yield(Any{key, val})
          @i += 1
        end
      end
    end

    @[Ignore]
    def parentloop=(@parentloop)
    end

    def length
      @collection.size
    end

    def parentloop
    end

    def index
      @i + 1
    end

    def index0
      @i
    end

    def rindex
      length - @i
    end

    def rindex0
      length - @i - 1
    end

    def first
      @i.zero?
    end

    def last
      @i == length - 1
    end
  end
end
