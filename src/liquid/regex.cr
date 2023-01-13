module Liquid
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

  VARIABLE_SIGNATURE = /\(?[\w\-\.\[\]]\)?/
end
