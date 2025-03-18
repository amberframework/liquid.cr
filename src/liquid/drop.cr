require "./any"

module Liquid
  # Drop methods with this annotation arent' exported to liquid.
  annotation Ignore
  end

  abstract class Drop
    macro inherited
      {% verbatim do %}
      macro finished
        def call(method : String) : Liquid::Any
          case method
          {% for method in @type.methods %}
            {% if method.args.size == 0 && method.visibility == :public && !method.annotation(Liquid::Ignore) %}
              when {{ method.name.stringify }}
                ret = {{ method.name.id }}
                ret.is_a?(Liquid::Any) ? ret : Liquid::Any.new(ret)
            {% end %}
          {% end %}
          else
            super
          end
        end
      end
      {% end %}
    end

    # Called by `StackMachine` to call a method from this `Drop`.
    # Only public methods without parameters can be called here
    def call(method : String) : Liquid::Any
      raise Liquid::InvalidExpression.new("Method #{method} not found for #{self.class.name}.")
    end

    # Alias to `#call`.
    def [](method : String) : Liquid::Any
      call(method)
    end
  end
end

class String
  def ==(other : Liquid::Drop)
    other == self
  end
end

struct Nil
  def ==(other : Liquid::Drop)
    other == self
  end
end

class Array
  def ==(other : Liquid::Drop)
    other == self
  end
end
