require "./spec_helper"

describe Liquid do
  describe Block do
    describe If do
      it "should add elsif node" do
        ifnode = If.new "if true == true"
        elsifnode = ElsIf.new "elsif true == false"
        ifnode << elsifnode
        ifnode.elsif.should_not be_nil
      end

      it "should render if true" do
        ifnode = If.new "if var"
        ifnode << Block::Raw.new "ok"
        node_output(ifnode, Context{"var" => "exists"}).should eq "ok"
        node_output(ifnode, Context{"var" => 0}).should eq "ok"
      end

      it "should not render if false" do
        ifnode = If.new "if var"
        ifnode << Block::Raw.new "ok"
        node_output(ifnode, Context{"var" => false}).should eq ""
        node_output(ifnode, Context.new).should eq ""
        node_output(ifnode, Context{"var" => nil}).should eq ""
      end
    end

    describe Case do
      it "should be inherit BeginBlock" do
        Case.new("case variable").should be_a BeginBlock
      end

      it "should add when node" do
        case_node = Case.new("case animal")
        case_node << When.new("when \"cat\"")
        case_node.when.should_not be_nil
      end

      it "should add else node" do
        case_node = Case.new("case animal")
        case_node << When.new("when \"cat\"")
        case_node << Else.new("else")
        case_node.else.should_not be_nil
      end

      it "should NOT add else node without a when" do
        case_node = Case.new("case var")
        expect_raises(Liquid::InvalidNode, "Else without When in Case statement!") do
          case_node << Else.new("else")
        end
      end

      it "should NOT add any when after an else" do
        case_node = Case.new("case animal")
        case_node << When.new("when \"cat\"")
        case_node << Else.new("else")
        expect_raises(Liquid::InvalidNode, "When statement must preceed Else!") do
          case_node << When.new("when \"dog\"")
        end
      end

      it "should render case" do
        case_node = Block::Case.new("case desert")
        case_node << Block::Raw.new("")
        when_node = Block::When.new("when \"cake\"")
        when_node << Block::Raw.new("This is a cake")
        case_node << when_node
        when_node = Block::When.new("when \"cookie\", \"biscuit\"")
        when_node << Block::Raw.new("This is a cookie")
        case_node << when_node
        when_node = Block::When.new("when 'potato'")
        when_node << Block::Raw.new("This is a potato")
        case_node << when_node
        when_node = Block::When.new("when 'potato', 'tomato'")
        when_node << Block::Raw.new("This is a tomato")
        case_node << when_node
        else_node = Block::Else.new("")
        else_node << Block::Raw.new("This is not a cake nor a cookie")
        case_node << else_node

        node_output(case_node, Context{"desert" => "cake"}).should eq "This is a cake"
        node_output(case_node, Context{"desert" => "cookie"}).should eq "This is a cookie"
        node_output(case_node, Context{"desert" => "biscuit"}).should eq "This is a cookie"
        node_output(case_node, Context{"desert" => "potato"}).should eq "This is a potato"
        node_output(case_node, Context{"desert" => "tomato"}).should eq "This is a tomato"
        node_output(case_node, Context{"desert" => "jellybean"}).should eq "This is not a cake nor a cookie"
      end
    end

    describe For do
      it "should be inherit BeginBlock" do
        For.new("for x in array").should be_a BeginBlock
      end

      it "should loop over array" do
        stmt = For.new "for x in myarray"
        stmt << Expression.new "x"
        ctx = Context.new
        ctx.set("myarray", Any{"apple", 12})
        node_output(stmt, ctx).should eq "apple12"
      end
    end

    describe Capture do
      it "should capture the content of the block" do
        block = Capture.new "capture mavar"
        block << Block::Raw.new "Hello World!"
        ctx = Context.new
        node_output(block, ctx)
        ctx.get("mavar").should eq "Hello World!"
      end
    end

    describe Increment do
    end

    describe Decrement do
    end

    describe Include do
      it "should include a page" do
        filename = "spec/data/include.html"
        expr = Include.new "include    \"#{filename}\""
        expr2 = Include.new "include \"#{filename}\""
        expr3 = Include.new "include \"#{filename}\"     "

        expr.template_name.should eq filename
        expr2.template_name.should eq filename
        expr3.template_name.should eq filename
      end

      it "should include a page with variable" do
        template_name = "spec/data/color"
        filename = "#{template_name}.liquid"
        varname = File.basename(template_name)
        varvalue = "red"

        expr = Include.new "include \"#{template_name}\" with \"#{varvalue}\""
        ctx = Context.new

        expr.accept RenderVisitor.new ctx
        expr.template_name.should eq filename
        ctx.get(varname).should eq varvalue
      end

      it "should include a page with multi variables" do
        ctx = Context.new
        template_name = "spec/data/color.liquid"
        template_vars = {
          "string"  => "\"green\"",
          "integer" => 20,
          "float"   => 3.0,
          "bool"    => true,
        }

        parse_text = "include \"#{template_name}\""
        template_vars.each do |k, v|
          parse_text += ", #{k}: #{v}"
        end

        expr = Include.new parse_text
        expr.accept RenderVisitor.new ctx

        expr.template_name.should eq template_name
        ctx.get("string").should eq "green"
        ctx.get("integer").should eq 20
        ctx.get("float").should eq 3.0
        ctx.get("bool").should be_true
      end
    end

    describe Assign do
      it "should assign a value" do
        expr = Assign.new "assign bool = true"
        expr2 = Assign.new "assign str = \"test\""
        expr3 = Assign.new "assign int = 12"
        ctx = Context.new

        expr.accept RenderVisitor.new ctx
        expr2.accept RenderVisitor.new ctx
        expr3.accept RenderVisitor.new ctx

        ctx.get("bool").should be_true
        ctx.get("str").should eq "test"
        ctx.get("int").should eq 12
      end
    end

    describe Filtered do
      it "should filter a string" do
        node = Filtered.new " \"whatever\" | abs"
        node_output(node).should eq "whatever"
      end

      it "should filter a int" do
        node = Filtered.new "-12 | abs"
        node_output(node).should eq "12"
      end

      it "should filter a float" do
        node = Filtered.new "-12.25 | abs"
        node_output(node).should eq "12.25"
      end

      it "should filter a var" do
        node = Filtered.new "var | abs"
        ctx = Context{"var" => -12}
        node_output(node, ctx).should eq "12"
      end

      it "should use multiple filters" do
        node = Filtered.new "var | append: \"Hello \" | append: \"World !\""
        ctx = Context{"var" => ""}
        node_output(node, ctx).should eq "Hello World !"
      end

      it "should filter with an argument" do
        node = Filtered.new "var | append: var2"
        ctx = Context{"var" => "Hello", "var2" => " World !"}
        node_output(node, ctx).should eq "Hello World !"
      end
    end

    describe Expression do
      it "should eval true" do
        expr = Expression.new "true"
        expr.eval(Context.new).should be_true
      end

      it "should eval false" do
        expr = Expression.new "false"
        expr.eval(Context.new).should be_false
      end

      it "should eval float" do
        expr = Expression.new "12.5"
        expr2 = Expression.new "-120.5"
        expr.eval(Context.new).should eq 12.5
        expr2.eval(Context.new).should eq -120.5
      end

      it "should eval a var" do
        expr = Expression.new "myvar"
        expr2 = Expression.new "myvar.inner"
        expr3 = Expression.new "myvar.inner.inner"

        ctx = Context.new
        ctx.set("myvar", true)
        ctx.set("myvar.inner", false)
        ctx.set("myvar.inner.inner", "good")

        expr.eval(ctx).should be_true
        expr2.eval(ctx).should be_false
        expr3.eval(ctx).should eq "good"
      end

      it "should eval an comparison" do
        expr = Expression.new "true == false"
        expr2 = Expression.new "true != false"
        expr3 = Expression.new "var != 15"
        expr3a = Expression.new "-var == -16"
        expr4 = Expression.new "str == 'asdf'"
        expr5 = Expression.new "!false && !flag"
        expr5a = Expression.new "!flag && !false"
        expr6 = Expression.new "missing?"

        ctx = Context.new(strict: true)
        ctx.set "var", 16
        ctx.set "str", "asdf"
        ctx.set "flag", false

        expr.eval(ctx).should be_false
        expr2.eval(ctx).should be_true
        expr3.eval(ctx).should be_true
        expr3a.eval(ctx).should be_true
        expr4.eval(ctx).should be_true
        expr5.eval(ctx).should be_true
        expr5a.eval(ctx).should be_true
        expr6.eval(ctx).raw.should be_nil # return value is Any which is not nil; need to check #raw instead
      end
      # it "should eval an operation with contains keyword" do
      #   expr = Expression.new "myarr contains another"
      #   ctx = Context.new
      #   ctx.set "myarr", [12,15,13]
      #   ctx.set "another", 12
      #   expr.eval(ctx).should be_true
      # end
      it "should eval an multiple operation" do
        expr = Expression.new "test == false or some == true or another == 10"
        expr2 = Expression.new "test != false or some == false or another == 10"
        expr3 = Expression.new "test != false and some != false and another == 15 and str == 'asdf'"

        ctx = Context.new
        ctx.set "test", true
        ctx.set "some", true
        ctx.set "another", 15
        ctx.set "str", "asdf"

        expr.eval(ctx).should be_true
        expr2.eval(ctx).should be_true
        expr3.eval(ctx).should be_true
      end
    end
  end
end
