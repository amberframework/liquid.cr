# Copyright (c) 2022 Acumera Inc
# Copyright (c) 2005, 2006 Tobias Luetke
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require "./token"

module Liquid
  class Tokenizer
    TagStart              = /(?<!\\)\{\%/
    TagEnd                = /\%\}/
    VariableSegment       = /[\w\-]/
    VariableStart         = /(?<!\\)\{\{/
    VariableEnd           = /\}\}/
    VariableIncompleteEnd = /\}\}?/
    QuotedString          = /"[^"]*"|'[^']*'/
    QuotedFragment        = /#{QuotedString}|(?:[^\s,\|'"]|#{QuotedString})+/
    TagAttributes         = /(\w[\w-]*)\s*\:\s*(#{QuotedFragment})/
    AnyStartingTag        = /#{TagStart}|#{VariableStart}/
    PartialTemplateParser = /#{TagStart}.*?#{TagEnd}|#{VariableStart}.*?#{VariableIncompleteEnd}/m
    TemplateParser        = /(#{PartialTemplateParser}|#{AnyStartingTag})/m
    VariableParser        = /\[[^\]]+\]|#{VariableSegment}+\??/

    def self.parse(string : String, &) : Nil
      line_number = 1

      string.split(TemplateParser) do |value|
        next if value.empty?

        yield(Token.new(value, line_number))
        line_number += string.count('\n')
      end
    end
  end
end
