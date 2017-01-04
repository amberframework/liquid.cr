require "./liquid"

filename = ARGV[0]
raise "Liquid template: #{filename} doesn't exist." unless File.exists?(filename)

io = ARGV[1]

tpl = Liquid::Template.parse File.read(filename)
visitor = Liquid::CodeGen2Visitor.new STDOUT
puts "begin"
puts <<-EOF
context = Liquid::Context.new
\{% for var in @type.instance_vars %}
    context.set \{{var.id.stringify}}, \{{var}}
\{% end %}
EOF
tpl.root.accept visitor
puts "#{io} << Liquid::Template.new(root).render context"
puts "end"
