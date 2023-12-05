# https://miking.org/

# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*\.mc$ %{
    set-option buffer filetype mcore
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=mcore %{
    require-module mcore
    set-option window static_words %opt{mcore_static_words}
}

hook -group mcore-highlight global WinSetOption filetype=mcore %{
    add-highlighter window/mcore ref mcore
    hook -once -always window WinSetOption filetype=.* %{
        remove-highlighter window/mcore
    }
}

# Comments
# ‾‾‾‾‾‾‾‾

hook global BufSetOption filetype=mcore %{
    set-option buffer comment_line '--'
    set-option buffer comment_block_begin '/-'
    set-option buffer comment_block_end '-/'
}

provide-module mcore %{

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter shared/mcore regions
add-highlighter shared/mcore/code default-region group
add-highlighter shared/mcore/string region (?<!\\)" (?<!\\)(\\\\)*" fill string
add-highlighter shared/mcore/comment region -- $ fill comment
add-highlighter shared/mcore/multiline-comment region /- -/ fill comment

add-highlighter shared/mcore/code/char regex %{\B'([^'\\]|(\\[\\"'nrt]))'\B} 0:value

# integer literals
add-highlighter shared/mcore/code/ regex \b-?[0-9]+\b 0:value

# float literals
add-highlighter shared/mcore/code/ regex \b-?[0-9]+(\.[0-9]*)? 0:value

# operators
# TODO: not sure if these are nice
add-highlighter shared/mcore/code/ regex [|&=] 0:operator
add-highlighter shared/mcore/code/ regex -> 0:operator

# Macro
# ‾‾‾‾‾

evaluate-commands %sh{
  meta="include|mexpr"

  keywords="all|case|con|else|end|external|if|in|lam|lang|let|match|recursive|sem|switch|syn|then|type|use|using|utest|with|hole|independent|accelerate|loop"

  types="Int|Float|Bool|Char|String|Tensor"

  intrinsics="addi|subi|muli|divi|modi|negi|slli|srli|srai|lti|leqi|gti|geqi|eqi|neqi|addf|subf|mulf|divf|negf|ltf|leqf|gtf|geqf|eqf|neqf|floorfi|ceilfi|roundfi|int2float|eqc|char2int|int2char|stringIsFloat|string2float|float2string|create|createRope|createList|isRope|isList|length|concat|get|set|cons|snoc|splitAt|reverse|unsafeCoerce|head|tail|null|map|mapi|iter|iteri|foldl|foldr|subsequence|randIntU|randSetSeed|wallTimeMs|sleepMs|print|printError|dprint|flushStdout|flushStderr|readLine|readBytesAsString|argv|readFile|writeFile|fileExists|deleteFile|command|error|exit|constructorTag|eqsym|gensym|sym2hash|ref|deref|modref|tensorCreateUninitInt|tensorCreateUninitFloat|tensorCreateCArrayInt|tensorCreateCArrayFloat|tensorCreateDense|tensorGetExn|tensorSetExn|tensorLinearGetExn|tensorLinearSetExn|tensorRank|tensorShape|tensorReshapeExn|tensorCopy|tensorTransposeExn|tensorSliceExn|tensorSubExn|tensorIterSlice|tensorEq|tensor2string|bootParserParseMExprString|bootParserParseMCoreFile|bootParserGetId|bootParserGetTerm|bootParserGetType|bootParserGetString|bootParserGetInt|bootParserGetFloat|bootParserGetListLength|bootParserGetConst|bootParserGetPat|bootParserGetInfo"

  bool_values="false|true"

  printf %s\\n "declare-option str-list mcore_static_words ${keywords}|${types}|${bool_values}|${intrinsics}" | tr '|' ' '

  printf %s "
    add-highlighter shared/mcore/code/ regex \b(${keywords})\b 0:keyword
    add-highlighter shared/mcore/code/ regex \b(${meta})\b 0:meta
    add-highlighter shared/mcore/code/ regex \b(${types})\b 0:type
    add-highlighter shared/mcore/code/ regex \b(${intrinsics})\b 0:builtin
    add-highlighter shared/mcore/code/ regex \b(${bool_values})\b 0:value
  "
}

}

