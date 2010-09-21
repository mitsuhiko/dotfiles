" Vim syntax file
" Language:	Genshi Template
" Maintainer:	Armin Ronacher <armin.ronacher@active-4.com>
" Last Change:	2007 Apr 22
" Version:	0.1
"
" Just works for HTML templates

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

if !exists("main_syntax")
  let main_syntax = 'html'
endif

" Source the html syntax file
ru! syntax/html.vim
unlet b:current_syntax

" Put the python syntax file into @pythonTop
syn include @pythonTop syntax/python.vim

" Variables
syn region genshiNested start="{" end="}" transparent display contained contains=genshiNested,@pythonTop
syn region genshiVariable matchgroup=genshiDelim start=#\${# end=#}# contains=genshiNested,@pythonTop containedin=ALL

" Helpers
syn match genshiEscape "&[^;]\+;" contained
syn region genshiAttrRegion matchgroup=htmlString start='"' end='"' keepend contained contains=genshiEscape,@pythonTop
syn region genshiAttrRegion matchgroup=htmlString start="'" end="'" keepend contained contains=genshiEscape,@pythonTop

" Genshi Attributes
syn match genshiAttr "\<py:\(for\|if\|choose\|when\|otherwise\|def\|match\|with\|content\|replace\|strip\|attrs\)\s*=\s*" contained containedin=htmlTag nextgroup=genshiAttrRegion

" Genshi Tags
syn match genshiTagAttr "\<test\|each\|function\|path\|\>=" contained nextgroup=genshiAttrRegion
syn match genshiTag "\<py:\(for\|if\|def\|match\|with\)\>" contained containedin=htmlTagN
syn region htmlTag start="<py:\(for\|if\|def\|match\|with\)" end=">" keepend contains=genshiTag,genshiTagAttr,htmlString,htmlArg,htmlValue,htmlEvent,htmlCssDefinition,@htmlPreproc,@htmlArgCluster


" Default highlighting links
if version >= 508 || !exists("did_genshi_syn_inits")
  if version < 508
    let did_genshi_syn_inits = 1
    com -nargs=+ HiLink hi link <args>
  else
    com -nargs=+ HiLink hi def link <args>
  endif

  HiLink genshiDelim Preproc
  HiLink genshiAttr Preproc
  HiLink genshiTag Preproc
  HiLink genshiTagAttr Preproc
  HiLink genshiEscape Special

  delc HiLink
endif

let b:current_syntax = "genshi"
