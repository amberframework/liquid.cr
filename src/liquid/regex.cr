module Liquid
  OPERATOR = /==|!=|<=|>=|<|>|contains/

  DQSTRING = /"([^"]|\\")*"/
  SQSTRING = /'([^']|\\')*'/
  STRING   = /(?:#{DQSTRING})|(?:#{SQSTRING})/
  INT      = /(?:0|(?:-*[1-9][0-9]*))/
  FLOAT    = /-*[0-9]+\.[0-9]+/
  BOOL     = /(?:false)|(?:true)/
  SCALAR   = /(?:#{STRING})|(?:#{FLOAT})|(?:#{INT})|(?:#{BOOL})/
  ARRAY    = /\[(#{SCALAR}(?:\s*,\s*#{SCALAR})*)\]/
  TYPE     = /(?:#{SCALAR})|(?:#{ARRAY})/

  VAR = /([-!]*(?<varbasename>[A-Za-z_]\w*)(?:(?<property>\.[A-Za-z_]\w*)|(?:\[(?<index>(?:#{STRING})|(?:#{INT})|(?1))\]))*\??)/

  TYPE_OR_VAR = /(?:#{TYPE})|(?:#{VAR})/
  CMP         = /(?:#{TYPE_OR_VAR})\s*(?:#{OPERATOR})\s*(?:#{TYPE_OR_VAR})/
  GCMP        = /(?<left>#{TYPE_OR_VAR})\s*(?<op>#{OPERATOR})\s*(?<right>#{TYPE_OR_VAR})/

  GSTRING = /^(?:"(?<str>[^"]*)")|(?:'(?<str>[^']*)')$/
  GINT    = /(?<intval>#{INT})/
  GFLOAT  = /(?<floatval>#{FLOAT})/

  FILTER_ARG  = TYPE_OR_VAR
  FILTER_ARGS = /#{FILTER_ARG}(?:,\s*#{FILTER_ARG})*/
  GFILTER     = /(?<filter>#{VAR})(?::\s*(?<args>#{FILTER_ARGS}))?/
  GFILTERED   = /(?<first>#{TYPE_OR_VAR})(\s*\|\s*(#{GFILTER}))+/

  CMPEXPR  = /\s*?#{GCMP}\s*?/
  BOOLEXPR = /\s*?!?(?<bool>#{BOOL})\s*?/
  EXPR     = /(?:#{CMPEXPR})|(?:#{BOOLEXPR})|(?:#{VAR})/

  BOOLOP        = /(?:\s+(?:or|and)\s+)|(?:\s*(?:&&|\|\|)\s*)/
  MULTIPLE_EXPR = /(?:(?<boolop>(?:#{BOOLOP})))?(?<expr>#{EXPR})/
end
