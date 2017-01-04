require "./liquid"
require "./liquid/codegen2_visitor"

filename = ARGV[0]
raise "Liquid template: #{filename} doesn't exist." unless File.exists?(filename)

tpl = Liquid::Template.parse File.read(filename)
visitor = Liquid::CodeGen2Visitor.new STDOUT
tpl.root.accept visitor
STDOUT << "Liquid::Template.new root"
