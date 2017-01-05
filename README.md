# liquid
[![Build Status](https://travis-ci.org/TechMagister/liquid.cr.svg?branch=master)](https://travis-ci.org/TechMagister/liquid.cr)

Liquid template engine for Crystal.

Liquid templating language : [http://shopify.github.io/liquid/](http://shopify.github.io/liquid/)

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
ctx = Liquid::Context.new
ctx.set "kenny", { "sick" => false, "dead" => true}

tpl = Liquid::Template.parse txt  # tpl can be cached and reused

result = tpl.render ctx

# result = "
#      You killed Kenny!  You ***!!!
#
#    "

```

Tags can be escaped :
``` liquid
\{% assign myvar = 15 %}
```
will render `{% assign myvar = 15 %}`

# Blocks
Cache block ( only support caching using redis ) : https://github.com/TechMagister/liquid-cache.cr

# Filters
- [x] abs
- [x] append
- [x] capitalize
- [x] ceil
- [x] date
- [x] default
- [x] escape
- [x] newline_to_br
- [x] split
- [ ] compact
- [ ] divided_by
- [ ] downcase
- [ ] escape_once
- [ ] first
- [ ] floor
- [ ] join
- [ ] last
- [ ] lstrip
- [ ] map
- [ ] minus
- [ ] modulo
- [ ] plus
- [ ] prepend
- [ ] remove
- [ ] remove_first
- [x] replace
- [ ] replace_first
- [ ] reverse
- [ ] round
- [ ] rstrip
- [ ] size
- [ ] slice
- [ ] sort
- [ ] sort_natural
- [ ] strip
- [ ] strip_html
- [ ] strip_newlines
- [ ] times
- [ ] truncate
- [ ] truncatewords
- [ ] uniq

## Development

TODO:
- [x] Basic For loops
- [x] Basic If Elsif Else
- [x] Add variable assignment ( {% assign var = "Hello World" %} )
- [x] Add support for multiple operator ( no operator precedence support ( for now ))
- [x] Add support for Array into for loop
- [x] Add support for Hash into for loop ( {% for key, val in myhash %} )
- [x] Add support for Float
- [x] Add iteration over Arrays
- [x] Improve data interface
- [x] Add Filter support
- [x] Add capture block
- [x] Add increment block
- [ ] Add decrement block
- [ ] Add "contains" keyword
- [ ] Add support for Array into expressions
- [ ] Add case/when
- [ ] Add syntax checking
- [ ] Improve expression parsing
- [ ] Add Everything that's missing [https://shopify.github.io/liquid/]


## Contributing

1. Fork it ( https://github.com/TechMagister/liquid.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [TechMagister](https://github.com/TechMagister) Arnaud Fernandés - creator, maintainer
