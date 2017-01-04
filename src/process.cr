require "json"
require "./liquid"

filename, io = ARGV[0], ARGV[1]
raise "Liquid template: #{filename} doesn't exist." unless File.exists?(filename)

tpl = Liquid::Template.parse File.read(filename)
tpl.to_code io, STDOUT
