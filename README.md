# liquid - Liquid template engine for Crystal
[![Build Status](https://github.com/TechMagister/liquid.cr/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/TechMagister/liquid.cr/actions/workflows/ci.yml)
[![Version](https://img.shields.io/github/tag/TechMagister/liquid.cr.svg?maxAge=360)](https://github.com/TechMagister/liquid.cr/releases/latest)
[![License](https://img.shields.io/github/license/TechMagister/liquid.cr.svg)](https://github.com/TechMagister/liquid.cr/blob/master/LICENSE)

Liquid templating language: [http://shopify.github.io/liquid/](http://shopify.github.io/liquid/)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  liquid:
    github: amberframework/liquid.cr
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
ctx.set "kenny", Any{ "sick" => false, "dead" => true}

tpl = Liquid::Template.parse txt  # tpl can be cached and reused

result = tpl.render ctx

# result = "
#      You killed Kenny!  You ***!!!
#
#    "

```

Tags can be escaped:
``` liquid
\{% assign myvar = 15 %}

# or

{% raw %}
{% assign myvar = 15 %}
{% endraw %}
```
will both render `{% assign myvar = 15 %}`.

# Blocks
Cache block (only supports caching using Redis): https://github.com/TechMagister/liquid-cache.cr

# Filters
- [x] abs
- [x] append
- [ ] at_least
- [ ] at_most
- [x] capitalize
- [x] ceil
- [x] compact
- [ ] concat
- [x] date
- [x] default
- [x] divided_by
- [x] downcase
- [x] escape
- [x] escape_once
- [x] first
- [x] floor
- [x] join
- [x] last
- [x] lstrip
- [x] map
- [x] minus
- [x] modulo
- [x] newline_to_br
- [x] plus
- [x] prepend
- [x] remove
- [x] remove_first
- [x] replace
- [x] replace_first
- [x] reverse
- [x] round
- [x] rstrip
- [x] size
- [x] slice
- [ ] sort
- [ ] sort_natural
- [x] split
- [x] strip
- [x] strip_html
- [x] strip_newlines
- [ ] times
- [ ] truncate
- [ ] truncatewords
- [ ] uniq
- [x] upcase
- [ ] url_decode
- [ ] url_encode
- [ ] where

# Helper Methods
- [x] size (for Array and String)
- [x] present / blank (added)
- [ ] first / last

## Development

TODO:
- [x] Basic For loops
- [x] if/elsif/else/endif
- [x] unless/endunless
- [x] Raw and comment blocks ({% raw %} and {% comment %})
- [x] Add variable assignment ({% assign var = "Hello World" %})
- [x] Add support for multiple operator (no operator precedence support (for now))
- [x] Add support for Array into for loop
- [x] Add support for Hash into for loop (`{% for val in myhash %}`, access as `val[0]` and `val[1]`)
- [ ] Add support for Hash into for loop ({% for key, val in myhash %}) (new)
- [x] Add support for Float
- [x] Add iteration over Arrays
- [x] Improve data interface
- [x] Add Filter support
- [x] Add `capture` block
- [x] Add `increment` block
- [x] Add `decrement` block
- [x] Add support for Array in expressions
- [x] Add support for Hash in expressions
- [x] Add "secret" `empty` Array (`[]`) for use in comparisons (equivalent to `#blank` helper method)
- [x] Add `contains` operator
- [ ] Add `cycle` keyword
- [ ] Add `starts_with` keyword (new)
- [ ] Add `ends_with` keyword (new)
- [ ] Add `continue` keyword
- [ ] Add `break` keyword
- [X] Add case/when
- [ ] Add syntax checking
- [x] Improve expression parsing
- [x] Add optional strict mode on Context (see below)
- [ ] Add Everything that's missing [https://shopify.github.io/liquid/]

## Context Strict Mode

NOTE: Will eventually use this to implement a `strict_variables` rendering flag (planning to implement `strict_filters` as well).

Enable at initialization:
```crystal
ctx = Liquid::Context.new(:strict)
```

Or on an existing Context:
```crystal
ctx.error_mode = :strict
```

Raises `Liquid::InvalidExpression` on missing keys and silently emit `nil` on array out of bounds.

Append `?` to emit nil in strict mode (very simplistic, just checks for `?` at the end of the identifier)

```crystal
ctx = Liquid::Context.new(:strict)
ctx["obj"] = { something: "something" }
```

```liquid
{{ missing }}          -> nil, but generates a UndefinedVariable errors if not in Lax mode.
{{ obj.missing }}      -> InvalidExpression
{{ missing.missing? }} -> generates a UndefinedVariable error, evaluates `missing` to nil then raises a InvalidExpression due to `nil.missing` call.
```

## Contributing

1. Fork it ( https://github.com/amberframework/liquid.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [TechMagister](https://github.com/TechMagister) Arnaud Fernandés - creator, maintainer of [original version](https://github.com/TechMagister/liquid.cr)
- [docelic](https://github.com/docelic) Davor Ocelic
- [anamba](https://github.com/anamba) Aaron Namba
