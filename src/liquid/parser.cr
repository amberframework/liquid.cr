module Liquid
  module Grammar
    whitespace = /[ \t\r\n]/ # _{ ([" "] | ["\t"] | ["\r"] | ["\n"])+ }

    # basic blocks of the language
    op_or = "or"
    op_wrong_or = "||"
    op_and = "and"
    op_wrong_and = "&&"
    op_lte = "<="
    op_gte = ">="
    op_lt = "<"
    op_gt = ">"
    op_eq = "=="
    op_ineq = "!="
    op_plus = "+"
    op_minus = "-"
    op_times = "*"
    op_slash = "/"
    op_true = "true"
    op_false = "false"
    boolean = /#{op_true}|#{op_false}/ # op_true | op_false
    op_filter = "|"

    int = /-?(0|([1-9][0-9]*))/
    # float = @{
    #    ["-"]? ~
    #        ["0"] ~ ["."] ~ ['0'..'9']+ |
    #        ['1'..'9'] ~ ['0'..'9']* ~ ["."] ~ ['0'..'9']+
    # }
    # // matches anything between 2 double quotes
    # string  = @{ ["\""] ~ (!(["\""]) ~ any )* ~ ["\""]}
    #
    # // FUNCTIONS
    # // Almost same as identifier minus no . allowed, used everywhere other
    # // than accessing context variables
    # simple_ident = @{
    #    (['a'..'z'] | ['A'..'Z'] | ["_"]) ~
    #    (['a'..'z'] | ['A'..'Z'] | ["_"] | ['0'..'9'])*
    # }
    #
    # // named args
    # fn_arg  = @{ simple_ident ~ ["="] ~ expression}
    # fn_args = !@{ fn_arg ~ ([","] ~ fn_arg )* }
    # fn_call = { simple_ident ~ ["("] ~ fn_args ~ [")"] | simple_ident }
    #
    # filters = { (op_filter ~ fn_call)+ }
    #
    # identifier = @{
    #    (['a'..'z'] | ['A'..'Z'] | ["_"]) ~
    #    (['a'..'z'] | ['A'..'Z'] | ["_"] | ["."] | ['0'..'9'])*
    # }
    # identifier_with_filter = { identifier ~ filters }
    # idents = _{ identifier_with_filter | identifier }
    #
    # // macros
    # // TODO: add default arg?
    # macro_param = @{ simple_ident }
    # macro_params = !@{ macro_param ~ ([","] ~ macro_param )* }
    # macro_definition = _{ identifier ~ ["("] ~ macro_params? ~ [")"]}
    # macro_call = { simple_ident ~ ["::"] ~ simple_ident ~ ["("] ~ fn_args? ~ [")"] }
    #
    # // Variable tests.
    # test_fn_param = { expression }
    # test_fn_params = {
    #    test_fn_param
    #    | (["("] ~ test_fn_param ~ ([","] ~ test_fn_param)* ~ [")"])
    # }
    # test_fn = !@{ simple_ident ~ test_fn_params? }
    # test = { ["is"] ~ test_fn }
    #
    # // Precedence climbing
    # expression = _{
    #    // boolean first so they are not caught as identifiers
    #    { boolean | string | idents | float | int }
    #    or          = { op_or | op_wrong_or }
    #    and         = { op_and | op_wrong_and }
    #    comparison  = { op_gt | op_lt | op_eq | op_ineq | op_lte | op_gte }
    #    add_sub     = { op_plus | op_minus }
    #    mul_div     = { op_times | op_slash }
    # }
    #
    # // Tera specific things
    #
    # // different types of blocks
    # variable_start = _{ ["{{"] }
    # variable_end   = _{ ["}}"] }
    # tag_start      = _{ ["{%"] }
    # tag_end        = _{ ["%}"] }
    # comment_start  = _{ ["{#"] }
    # comment_end    = _{ ["#}"] }
    # block_start    = _{ variable_start | tag_start | comment_start }
    #
    # // Actual tags
    # include_tag      = !@{ tag_start ~ ["include"] ~ string ~ tag_end }
    # import_macro_tag = !@{ tag_start ~ ["import"] ~ string ~ ["as"] ~ simple_ident ~ tag_end}
    # extends_tag      = !@{ tag_start ~ ["extends"] ~ string ~ tag_end }
    # variable_tag     = !@{ variable_start ~ (macro_call | expression) ~ variable_end }
    # super_tag        = !@{ variable_start ~ ["super()"] ~ variable_end }
    # comment_tag      = !@{ comment_start ~ (!comment_end ~ any )* ~ comment_end }
    # block_tag        = !@{ tag_start ~ ["block"] ~ identifier ~ tag_end }
    # macro_tag        = !@{ tag_start ~ ["macro"] ~ macro_definition ~ tag_end }
    # if_tag           = !@{ tag_start ~ ["if"] ~ expression ~ test? ~ tag_end }
    # elif_tag         = !@{ tag_start ~ ["elif"] ~ expression ~ test? ~ tag_end }
    # else_tag         = !@{ tag_start ~ ["else"] ~ tag_end }
    # for_tag          = !@{ tag_start ~ ["for"] ~ identifier ~ ["in"] ~ idents ~ tag_end }
    # raw_tag          = !@{ tag_start ~ ["raw"] ~ tag_end }
    # endraw_tag       = !@{ tag_start ~ ["endraw"] ~ tag_end }
    # endblock_tag     = !@{ tag_start ~ ["endblock"] ~ identifier ~ tag_end }
    # endmacro_tag     = !@{ tag_start ~ ["endmacro"] ~ identifier ~ tag_end }
    # endif_tag        = !@{ tag_start ~ ["endif"] ~ tag_end }
    # endfor_tag       = !@{ tag_start ~ ["endfor"] ~ tag_end }
    #
    # elif_block = { elif_tag ~ content* }
    # raw_text   = { (!endraw_tag ~ any )* }
    # text       = { (!(block_start) ~ any )+ }
    #
    # // smaller sets of allowed content in macros
    # macro_content = @{
    #    include_tag |
    #    variable_tag |
    #    comment_tag |
    #    if_tag ~ macro_content* ~ elif_block* ~ (else_tag ~ macro_content*)? ~ endif_tag |
    #    for_tag ~ macro_content* ~ endfor_tag |
    #    raw_tag ~ raw_text ~ endraw_tag |
    #    text
    # }
    #
    # // smaller set of allowed content in block
    # // currently identical as `macro_content` but will change when super() is added
    # block_content = @{
    #    include_tag |
    #    super_tag |
    #    variable_tag |
    #    comment_tag |
    #    block_tag ~ block_content* ~ endblock_tag |
    #    if_tag ~ block_content* ~ elif_block* ~ (else_tag ~ block_content*)? ~ endif_tag |
    #    for_tag ~ block_content* ~ endfor_tag |
    #    raw_tag ~ raw_text ~ endraw_tag |
    #    text
    # }
    #
    # content = @{
    #    include_tag |
    #    import_macro_tag |
    #    variable_tag |
    #    comment_tag |
    #    macro_tag ~ macro_content* ~ endmacro_tag |
    #    block_tag ~ block_content* ~ endblock_tag |
    #    if_tag ~ content* ~ elif_block* ~ (else_tag ~ content*)? ~ endif_tag |
    #    for_tag ~ content* ~ endfor_tag |
    #    raw_tag ~ raw_text ~ endraw_tag |
    #    text
    # }
    #
    # // top level rule
    # template = @{ soi ~ extends_tag? ~ content* ~ eoi }

  end
end
