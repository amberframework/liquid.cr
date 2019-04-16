module Liquid
  OPERATOR = /==|!=|<=|>=|<|>/

  DQSTRING = /"[^"]*"/
  SQSTRING = /'[^']*'/
  STRING   = /(?:#{DQSTRING})|(?:#{SQSTRING})/
  INT      = /(?:0|(?:-?[1-9][0-9]*))/
  FLOAT    = /-?[0-9]+\.[0-9]+/
  BOOL     = /(?:false)|(?:true)|(?:[01])|(?:nil)/
  TYPE     = /(?:#{STRING})|(?:#{FLOAT})|(?:#{INT})|(?:#{BOOL})/

  VAR = /((?<varbasename>[A-Za-z_]\w*)(?:(?<property>\.[A-Za-z_]\w*)|(?:\[(?<index>(?:#{STRING})|(?:#{INT})|(?1))\]))*\??)/

  TYPE_OR_VAR = /(?:#{TYPE})|(?:#{VAR})/
  CMP         = /(?:#{TYPE_OR_VAR})\s*(?:#{OPERATOR})\s*(?:#{TYPE_OR_VAR})/
  GCMP        = /(?<left>#{TYPE_OR_VAR})\s*(?<op>#{OPERATOR})\s*(?<right>#{TYPE_OR_VAR})/

  GSTRING = /^(?:"(?<str>[^"]*)")|(?:'(?<str>[^']*)')$/
  GINT    = /(?<intval>#{INT})/
  GFLOAT  = /(?<floatval>#{FLOAT})/

  FILTER    = /#{VAR}(?::\s*#{TYPE_OR_VAR}(?:,\s*#{TYPE_OR_VAR})*)?/
  GFILTER   = /(?<filter>#{VAR})(?::\s*(?<args>#{TYPE_OR_VAR}(?:,\s*#{TYPE_OR_VAR})*))?/
  FILTERED  = /#{TYPE_OR_VAR}(?:\s?\|\s?#{FILTER})+/
  GFILTERED = /(?<first>#{TYPE_OR_VAR})(\s?\|\s?(#{FILTER}))+/

  CMPEXPR  = /\s*?#{GCMP}\s*?/
  BOOLEXPR = /\s*?(?<bool>#{BOOL})\s*?/
  EXPR     = /(?:#{CMPEXPR})|(?:#{BOOLEXPR})/

  MULTIPLE_EXPR = /(?:(?<boolop>(\s+or|and\s+)|(\s*&&|\|\|\s*)))?(?<expr>#{EXPR})/
end
