# liquid

TODO: Write a description here

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  liquid:
    github: TechMagister/liquid.cr
```

## Usage

```crystal
require "liquid"

txt = "
    {% if kenny.sick %}
      Kenny is sick.
    {% elsif kenny.dead %}
      You killed Kenny!  You ***!!!
    {% else %}
      Kenny looks okay --- so far
    {% endif %}
    "
ctx = Context.new
ctx.set "kenny.sick", false
ctx.set "kenny.dead", true

tpl = Parser.parse txt
result = tpl.render ctx

# result = "
#      You killed Kenny!  You ***!!!
#    
#    "

```

## Development

TODO:
- [x] Basic For loops
- [x] Basic If Elsif Else
- [x] Add variable assignment ( {% assign var = "Hello World" %} )
- [ ] Add increment
- [ ] Add decrement
- [ ] Add capture
- [x] Add support for multiple operator ( no operator precedence support ( for now )) 
- [ ] Add "contains" keyword
- [ ] Add support for Array into expressions
- [x] Add support for Array into for loop
- [x] Add support for Float
- [ ] Add case/when
- [x] Add iteration over Arrays
- [ ] Add syntax checking
- [ ] Improve expression parsing
- [ ] Improve data interface
- [ ] Add filters
- [ ] Add Everything that's missing [https://shopify.github.io/liquid/]


## Contributing

1. Fork it ( https://github.com/TechMagister/liquid.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [TechMagister](https://github.com/TechMagister) Arnaud Fernandés - creator, maintainer
