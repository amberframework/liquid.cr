# Changelog

Arranged in reverse chronological order (latest changes on top).

## Unreleased

* [FIXED] Filters within loops no longer applied once per each completed loop iteration
* [NEW] Support Hash#size
* [NEW] Supports hash access, via string literal or string variable
* [FIXED] Accept single quoted strings
* [FIXED] Accept a wider range of complex boolean expressions
* [CHANGED] Context strict mode raises KeyError, IndexError, and Exception depending on situation
* [ADDED] Accept &&/|| in addition to and/or
* [ADDED] Allow use of - (negative) and ! (not) in expressions with literals and variables
* [ADDED] Added #present and #blank helper methods
* [ADDED] Added "secret" empty array ([]) for use in comparisons
* [ADDED] Added shopify liquid loop variables
* [ADDED] Implemented contains operator
* [ADDED] Implemented for loop over hash by array of key+value (for v in hash, where v[0] = key, v[1] = value)

## v0.4.0 - 2019-04-15

* First public release as anamba/liquid.cr
* [NEW] Added optional strict mode for Context
* [NEW] Support array access, via integer literal or integer variable
* [NEW] Support Array#size and String#size
* [FIXED] Treat zero as a valid integer to fix comparison w/zero, e.g. `{% if array.size > 0 %}`
