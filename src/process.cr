require "json"
require "./liquid"

filename, io, context = ARGV[0], ARGV[1], ARGV[2]?
raise "Liquid template: #{filename} doesn't exist." unless File.exists?(filename)

tpl = Liquid::Template.parse File.read(filename)
tpl.to_code io, STDOUT, context
