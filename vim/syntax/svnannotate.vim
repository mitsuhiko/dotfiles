if exists("b:current_syntax")
  finish
endif

syn match svnName /\S\+/ contained
syn match svnVer /^\s\+\d\+/ contained nextgroup=svnName skipwhite
syn match svnHead /^\s\+\d\+\s\+\S\+/ contains=svnVer,svnName

if !exists("did_svnannotate_syntax_inits")
  let did_svnannotate_syntax_inits = 1
  hi link svnName Function
  hi link svnVer Constant
endif

let b:current_syntax="svnannotate"
