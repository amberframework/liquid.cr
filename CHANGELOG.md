# Changelog

Arranged in reverse chronological order (latest changes on top).

## v0.4.0 - 2019-04-15

* First public release as anamba/liquid.cr
* [NEW] Added optional strict mode for Context
* [NEW] Support array access, via literal or variable index
* [NEW] Support Array#size and String#size
* [FIXED] Treat zero as a valid integer to fix comparison w/zero, e.g. `{% if array.size > 0 %}` 
