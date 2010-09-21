" Vim syntax file
" Language:		Werkzeug Templates
" Maintainer:		Armin Ronacher

if exists("b:current_syntax")
  finish
endif

if !exists("main_syntax")
  let main_syntax = 'werkzeug'
endif

if !exists("g:werkzeug_default_subtype")
  let g:werkzeug_default_subtype = 'html'
endif

if !exists("b:werkzeug_subtype") && main_syntax == 'werkzeug'
  let s:lines = getline(1)."\n".getline(2)."\n".getline(3)."\n".getline(4)."\n".getline(5)."\n".getline("$")
  let b:werkzeug_subtype = matchstr(s:lines,'werkzeug_subtype=\zs\w\+')
  if b:werkzeug_subtype == ''
    let b:werkzeug_subtype = matchstr(substitute(expand("%:t"),'\c\%(\.erb\)\+$','',''),'\.\zs\w\+$')
  endif
  if b:werkzeug_subtype == ''
    let b:werkzeug_subtype = g:werkzeug_default_subtype
  endif
endif

exe "runtime! syntax/".b:werkzeug_subtype.".vim"
unlet! b:current_syntax
syn include @pythonTop syntax/python.vim

syn cluster werkzeugRegions contains=werkzeugBlock,werkzeugExpression,werkzeugComment

syn keyword werkzeugEnd contained endfor endif endwhile
syn region werkzeugComment matchgroup=werkzeugDelim start="<%#" end=#%># keepend
syn region werkzeugBlock matchgroup=werkzeugDelim start=#<%# end=#%># keepend contains=@pythonTop,werkzeugEnd

syn match werkzeugDelim "\$" display nextgroup=werkzeugVar
syn region werkzeugVar matchgroup=werkzeugDelim start=#\${# end=#}# transparent contains=werkzeugNestedVar,@pythonTop
syn match werkzeugVar "[a-zA-Z_][a-zA-Z0-9_]*\(\.[a-zA-Z_][a–zA-Z0-9_]*\)*" display contained nextgroup=werkzeugNestedVar
syn region werkzeugNestedVar start="{" end="}" transparent display contained contains=werkzeugNestedVar,@pythonTop
syn region werkzeugNestedVar start="(" end=")" transparent display contained contains=werkzeugNestedVar,@pythonTop
syn region werkzeugNestedVar start="\[" end="\]" transparent display contained contains=werkzeugNestedVar,@pythonTop

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_werkzeug_syntax_inits")
  if version < 508
    let did_ruby_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink werkzeugDelim        Delimiter
  HiLink werkzeugComment      Comment
  HiLink werkzeugEnd          Keyword
  HiLink werkzeugChain        Operator
  HiLink werkzeugVar          pythonFunction

  delcommand HiLink
endif
let b:current_syntax = 'werkzeug'

if main_syntax == 'werkzeug'
  unlet main_syntax
endif

" vim: nowrap sw=2 sts=2 ts=8 ff=unix:
