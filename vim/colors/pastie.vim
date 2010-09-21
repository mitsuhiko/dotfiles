" Vim color file
" Maintainer:   Armin Ronacher
" License:      GPL (http://www.gnu.org)
"
" Based on the pygments pastie style that is based on the coderay default
" style which is used in the pastie pastebin. That's why the name
"

set background=light
hi clear          
if exists("syntax_on")
	syntax reset
endif
let g:colors_name="pastie"


" Default Colors
hi Normal	guifg=#111111	guibg=#ffffff
hi NonText	guifg=#444444	guibg=#eeeeee
hi Cursor	guibg=#cccccc
hi lCursor	guibg=#cccccc

" Search
hi Search	guifg=#800000	guibg=#ffae00
hi IncSearch	guifg=#800000	guibg=#ffae00

" Window Elements
hi StatusLine	guifg=#ffffff	guibg=#8090a0	gui=bold
hi StatusLineNC	guifg=#506070	guibg=#a0b0c0
hi VertSplit	guifg=#a0b0c0	guibg=#a0b0c0
hi Folded	guifg=#111111	guibg=#8090a0
hi IncSearch	guifg=#708090	guibg=#f0e68c
hi Pmenu	guifg=#ffffff	guibg=#cb2f27
hi CursorLine	guibg=#eeeeee
hi LineNr	guifg=#aaaaaa	guibg=#555555

" Syntax Elements
hi String	guifg=#dd2200	guibg=#fff0f0
hi Constant	guifg=#dd2200
hi Number	guifg=#0000dd	gui=bold
hi Statement	guifg=#008800	gui=bold
hi Function	guifg=#0066bb	gui=bold
hi PreProc	guifg=#888888	gui=bold
hi Comment	guifg=#888888
hi Type		guifg=#bb0066	gui=bold
hi Error	guifg=#dd0000	guibg=#f2f2f2
hi Identifier	guifg=#336699
hi Label	guifg=#336699
hi Todo		guifg=#dd0000	guibg=#f2f2f2	gui=bold

" Ruby Highlighting
hi rubyFunction		guifg=#0066bb	gui=bold
hi rubyKeyword		guifg=#008800	gui=bold
hi rubyDefine		guifg=#008800	gui=bold
hi rubyClass		guifg=#008800	gui=bold
hi rubyModule		guifg=#008800	gui=bold
hi rubyPseudoVariable	guifg=#003388
hi rubySymbol		guifg=#aa6600
hi rubyIdentifier	guifg=#336699
hi rubyASCIICode	guifg=#bb0066	gui=bold
hi rubyConstant		guifg=#003366	gui=bold
hi rubyPredefinedIdentifier	guifg=#003388	gui=bold
hi rubyString		guifg=#dd2200	guibg=#fff0f0
hi rubyStringDelimiter	guifg=#dd2200
hi rubyRegexp		guifg=#008800	guibg=#fff0ff
hi RubyRegexpDelimiter	guifg=#008800
hi rubyInterpolation	guifg=#dd2200	guibg=#fff0f0
hi rubyBlockParameter	guifg=#3333bb
hi rubyData		guifg=#555555
hi rubyDocumentation	guifg=#555555
hi rubyGlobalVariable	guifg=#dd7700
hi rubyInstanceVariable	guifg=#3333bb
hi rubyClassVariable	guifg=#336699
