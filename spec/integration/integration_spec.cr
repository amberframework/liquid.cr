require "yaml"
require "../spec_helper"

# [golden-liquid](https://github.com/jg-rp/golden-liquid) is a test suite for
# liquid template, tests are found in spec/integration/golden_liquid.yaml, a
# list of tests that are expected to fail can be found at
# spec/integration/golden_liquid.pending.
#
# All golden liquid tests are tagged with `golden`. Tests are run in two modes,
# using the render visitor directly (tagged with `render`) and using the
# codegen visitor (tagged with `codegen`), besides a numeric tag for each test.
#
# For code gen tests Crystal code is written in files like
# `spec/integration/codegen-test-XXX.cr` where XXX is the test number.
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
    raise "Bad context: #{@context}" if vars.nil?

    # Golden liquid run ruby tests with `render!`, that raises an exception on first error, this is the strict behavior
    # of liquid crystal.
    ctx = Context.new(@strict || @error ? Context::ErrorMode::Strict : Context::ErrorMode::Lax)
    vars.each do |key, value|
      ctx.set(key.as_s, yaml_any_to_liquid_any(value))
    end
    ctx
  end

  private def context_to_code(context : Liquid::Context) : String
    String.build do |str|
      str << "Liquid::Context{"
      context.each do |key, value|
        key.inspect(str)
        str << " => " << any_to_code(value)
        str << ", "
      end
      str << "}"
    end
  end

  private def any_to_code(any : Liquid::Any) : String
    raw = any.raw
    String.build do |str|
      str << "Liquid::Any.new("

      if raw.is_a?(Array)
        str << "["
        raw.each { |item| str << any_to_code(item) << ", " }
        str << "] of Liquid::Any"
      elsif raw.is_a?(Hash)
        str << "{"
        raw.each do |key, value|
          str << key.inspect << "=>" << any_to_code(value) << ", "
        end
        str << "} of String => Liquid::Any"
      else
        raw.inspect(str)
      end
      str << ")"
    end
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

  def codegen_test!(test_group, test_number)
    test_path = Path[__DIR__, "codegen-test-#{test_number}.cr"]
    test = File.open(test_path, "w")
    test.puts("# #{test_group.name}.#{@name}\n\n")
    generate_codegen_test_source(test)
    output = `crystal run #{Process.quote(test.path)} --error-trace`
    $?.exit_code.should eq(0)
    output.should eq(@want) unless @error
  end

  private def generate_codegen_test_source(io) : Nil
    error_mode = @strict || @error ? Context::ErrorMode::Strict : Context::ErrorMode::Lax

    io.puts(<<-CRYSTAL)
    require "../../src/liquid"

    TEMPLATE =<<-LIQUID
    #{Liquid::CodeGenVisitor.escape(@template)}
    LIQUID

    WANT =<<-TEXT
    #{Liquid::CodeGenVisitor.escape(@want)}
    TEXT

    #  CONTEXT
    expects_error = #{@error}
    context = #{context_to_code(context)}
    context.error_mode = :#{error_mode}

    #  CODEGEN OUTPUT
    CRYSTAL

    tpl = Liquid::Template.parse(@template)
    visitor = CodeGenVisitor.new(io)
    tpl.root.accept(visitor)
    io.puts(<<-CRYSTAL)
    begin
      Liquid::Template.new(root).render(context, STDOUT)
    rescue ex : Liquid::InvalidExpression
      raise ex unless expects_error
    end
    CRYSTAL

  rescue ex : Liquid::LiquidException
    io << "abort(" << ex.message.inspect << ") unless expects_error\n"
  ensure
    io.close
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
  skip_pending_tests = ENV["SKIP_PENDING"]?

  GoldenLiquid.from_yaml(File.read(File.join(__DIR__, "golden_liquid.yaml"))).test_groups.each do |test_group|
    describe test_group.name, tags: "golden" do
      test_group.tests.each do |test|
        if PendingGold.pending?(test_group.name, test.name)
          pending(test.name, line: i) unless skip_pending_tests
        else
          it "#{test.name} [test-#{i} render]", tags: ["test-#{i}", "render"] do
            test.test!
          end

          i += 1
          dup_i = i
          it "#{test.name} [test-#{i} codegen]", tags: ["test-#{i}", "codegen"] do
            test.codegen_test!(test_group, dup_i)
          end
        end
        i += 1
      end
    end
  end
end
