require "yaml"
require "../spec_helper"

class GoldenTest
  include YAML::Serializable

  getter name : String
  @template : String
  @want : String
  @error : Bool
  @context : YAML::Any
  @partials : Hash(String, String)
  @strict : Bool

  private def context : Liquid::Context
    vars = @context.as_h?
    raise "Bad context: #{@context.to_s}" if vars.nil?

    ctx = Context.new
    ctx.strict = @strict
    vars.each do |key, value|
      ctx.set(key.as_s, yaml_any_to_liquid_any(value))
    end
    ctx
  end

  def test!
    if @error
      expect_raises(LiquidException) do
        Parser.parse(@template).render(context).should eq(@want)
      end
    else
      Parser.parse(@template).render(context).should eq(@want)
    end
  end
end

class GoldenTestGroup
  include YAML::Serializable

  getter name : String
  getter tests : Array(GoldenTest)
end

class GoldenLiquid
  include YAML::Serializable

  getter version : String
  getter test_groups : Array(GoldenTestGroup)
end

private def yaml_any_to_liquid_any(yaml : YAML::Any) : Liquid::Any
  raw = yaml.raw
  case raw
  when Bool, Float64, Int64, String, Nil
    Liquid::Any.new(raw)
  when Array(YAML::Any)
    array = raw.map { |i| yaml_any_to_liquid_any(i) }
    Liquid::Any.new(array)
  when Hash(YAML::Any, YAML::Any)
    hash = raw.each_with_object(Hash(String, Liquid::Any).new) do |(key, value), obj|
      obj[key.to_s] = yaml_any_to_liquid_any(value)
    end
    Liquid::Any.new(hash)
  else
    abort(yaml.to_s)
  end
end

# FIXME: One all tests pass we must remove this class
class PendingGold
  @@pending : Array(String)?

  def self.pending?(group : String, name : String) : Bool
    pending = @@pending ||= File.read_lines(File.join(__DIR__, "golden_liquid.pending"))
    pending.includes?("#{group} #{name}")
  rescue File::NotFoundError
    false
  end
end

# Tests here use the Golden Liquid tests (https://github.com/jg-rp/golden-liquid) described at golden_liquid.yaml file.
describe "Golden Liquid Tests" do
  i = 1
  GoldenLiquid.from_yaml(File.read(File.join(__DIR__, "golden_liquid.yaml"))).test_groups.each do |test_group|
    describe test_group.name do
      test_group.tests.each do |test|
        if PendingGold.pending?(test_group.name, test.name)
          pending test.name, file: __FILE__, line: i
        else
          it test.name, file: __FILE__, line: i do
            test.test!
          end
        end
        i += 1
      end
    end
  end
end
