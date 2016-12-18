require "./spec_helper"

def gen_code(str)
  tpl = Liquid::Template.parse str
  io = IO::Memory.new
  tpl.to_code "__liquid__", io
  io.close
  io.to_s
end

describe Liquid do
  describe Liquid::CodeGenVisitor do
    it "should generate code for raw text" do
      gen_code("raw text").should eq("__liquid__ << \"root = Root.new\"\n__liquid__ << \"root << Raw.new(\\\"raw text\\\")\"\n__liquid__ << \"Template.new root\"\n")
    end

    it "should generate code for assign" do
      gen_code("{% assign toto=12 %}").should eq("__liquid__ << \"root = Root.new\"\n__liquid__ << \"root << Assign.new(\\\"toto\\\", Expression.new(\\\"12\\\"))\"\n__liquid__ << \"Template.new root\"\n")
    end

    it "should generate code for capture" do
      gen_code("{% capture mavar %}Hello World !{% endcapture %}").should eq("__liquid__ << \"root = Root.new\"\n__liquid__ << \"var1 = Capture.new(\\\"mavar\\\")\"\n__liquid__ << \"var1 << Raw.new(\\\"Hello World !\\\")\"\n__liquid__ << \"root << var1\"\n__liquid__ << \"Template.new root\"\n")
    end

    it "should generate code for For node" do
      gen_code("{% for x in 0..1 %}Hello World{% endfor %}").should eq("__liquid__ << \"root = Root.new\"\n__liquid__ << \"var1 = For.new(\\\"x\\\", 0, 1)\"\n__liquid__ << \"var1 << Raw.new(\\\"Hello World\\\")\"\n__liquid__ << \"root << var1\"\n__liquid__ << \"Template.new root\"\n")
    end

    it "should generate code for For node" do
      gen_code("{% for x in 0..1 %}Hello {{x}}{% endfor %}").should eq("__liquid__ << \"root = Root.new\"\n__liquid__ << \"var1 = For.new(\\\"x\\\", 0, 1)\"\n__liquid__ << \"var1 << Raw.new(\\\"Hello \\\")\"\n__liquid__ << \"var1 << Expression.new(\\\"x\\\")\"\n__liquid__ << \"root << var1\"\n__liquid__ << \"Template.new root\"\n")
    end

    it "should generate code for Expression" do
      gen_code("{{ true == false }}").should eq("__liquid__ << \"root = Root.new\"\n__liquid__ << \"root << Expression.new(\\\"true == false\\\")\"\n__liquid__ << \"Template.new root\"\n")
    end

    it "should generate code for Filtered Expression" do
      gen_code("{{var | abs}}").should eq("__liquid__ << \"root = Root.new\"\n__liquid__ << \"root << Expression.new(\\\"var | abs\\\")\"\n__liquid__ << \"Template.new root\"\n")
    end

    it "should generate code for if elsif else" do
      gen_code("{% if var %}some{% elsif var2 %}other{% else %}anything{% endif %}").should eq("__liquid__ << \"root = Root.new\"\n__liquid__ << \"var1 = Expression.new(\\\"var\\\")\"\n__liquid__ << \"var2 = If.new(var1)\"\n__liquid__ << \"var2 << Raw.new(\\\"some\\\")\"\n__liquid__ << \"var3 = ElsIf.new( Expression.new(\\\"var2\\\"))\"\n__liquid__ << \"var3 << Raw.new(\\\"other\\\")\"\n__liquid__ << \"var2 << var3\"\n__liquid__ << \"var4 = Else.new\"\n__liquid__ << \"var4 << Raw.new(\\\"anything\\\")\"\n__liquid__ << \"var2 << var4\"\n__liquid__ << \"root << var2\"\n__liquid__ << \"Template.new root\"\n")
    end
  end
end
