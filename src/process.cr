require "./liquid"

filename = ARGV[0]
raise "Liquid template: #{filename} doesn't exist." unless File.exists?(filename)

tpl = Template.parse filename
tpl.to_code ARGV[1], STDOUT
