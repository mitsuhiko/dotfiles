" Vim color file
" Maintainer:   flashdrv[12n]k @ Qnet|Freenode
" Last Change:	rubyforen.vim So Aug 14 2005
" URL:		flashdrvnk.dyndns.org/ruby/vimscheme/
" License:      GPL (http://www.gnu.org)
" Disclaimer:
"    This program is distributed in the hope that it will be useful,
"    but WITHOUT ANY WARRANTY; without even the implied warranty of
"    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"    GNU General Public License for more details.
" ----------------------------------------------------------------------------
"  Thanks to Jani Nurminen <jani.nurminen@intellitel.com> for zenburn.vim

set background=light
hi clear          
if exists("syntax_on")
    syntax reset
endif
let g:colors_name="rubyforen"

hi Boolean         guifg=#369    gui=bold
hi Character       guifg=#dca3a3 gui=bold
hi Comment         guifg=#888
hi Conditional     guifg=#f0dfaf gui=bold
hi Constant        guifg=#036    gui=bold
hi Cursor          guifg=#000d18 guibg=#8f9f9f gui=bold
hi Debug           guifg=#dca3a3 gui=bold
hi Define          guifg=#080    gui=bold
hi Delimiter       guifg=#d42    gui=bold
hi DelimiterRegexp guifg=#927    gui=bold
hi DiffAdd         guifg=#709080 guibg=#313c36 gui=bold
hi DiffChange      guibg=#333333
hi DiffDelete      guifg=#333333 guibg=#464646
hi DiffText        guifg=#ecbcbc guibg=#41363c gui=bold
hi Directory       guifg=#dcdccc gui=bold
hi ErrorMsg        guifg=#ffffe0 guibg=#f33f3f gui=bold
hi Exception       guifg=#c3bf9f gui=bold
hi Float           guifg=#60e    gui=bold
hi FoldColumn      guifg=#93b3a3 guibg=#3f4040
hi Folded          guifg=#93b3a3 guibg=#3f4040
hi Function        guifg=#06b    gui=bold
hi Identifier      guifg=#33b
hi IncSearch       guibg=#f8f893 guifg=#385f38
hi Include         guifg=#000
hi Keyword         guifg=#f0dfaf gui=bold
hi Label           guifg=#dfcfaf gui=underline
hi LineNr          guifg=#7f8f8f guibg=#464646
hi Macro           guifg=#ffcfaf gui=bold
hi ModeMsg         guifg=#d42    gui=none
hi MoreMsg         guifg=#ffffff gui=bold
hi NonText         guifg=#888
hi Normal          guifg=#000    gui=bold
hi Number          guifg=#00d    gui=bold
hi Operator        guifg=#f0efd0
hi PreCondit       guifg=#dfaf8f gui=bold
hi PreProc         guifg=#888
hi Question        guifg=#ffffff gui=bold
hi Repeat          guifg=#ffd7a7 gui=bold
hi rubyClassVariable guifg=#369
hi rubyConstant    guifg=#036    gui=bold
hi rubyGlobalVariable guifg=#800 gui=bold
hi rubyIterator guifg=#000
hi rubyPredefinedConstant guifg=#369 gui=bold
hi rubyPredefinedVariable guifg=#800 gui=bold
hi rubyPseudoVariable guifg=#369 gui=bold
hi rubySymbol      guifg=#a60
hi Search          guifg=#ffffe0 guibg=#9b3
hi SpecialChar     guifg=#d42    gui=bold
hi SpecialComment  guifg=#82a282 gui=bold
hi Special         guifg=#d42    gui=bold
hi SpecialKey      guifg=#9ece9e
hi Statement       guifg=#080    gui=bold
hi StatusLine      guifg=#1e2320 guibg=#acbc90
hi StatusLineNC    guifg=#2e3330 guibg=#88b090
hi StorageClass    guifg=#c3bf9f gui=bold
hi String          guifg=#d42    gui=bold
hi StringRegexp    guifg=#927    gui=bold
hi Structure       guifg=#efefaf gui=bold
hi Tag             guifg=#dca3a3 gui=bold
hi Title           guifg=#efefef guibg=#3f3f3f gui=bold
hi Todo            guifg=#7faf8f guibg=#3f3f3f gui=bold
hi Typedef         guifg=#dfe4cf gui=bold
hi Type            guifg=#b06    gui=bold
hi Underlined      guifg=#dcdccc guibg=#3f3f3f gui=underline
hi VertSplit       guifg=#303030 guibg=#688060
hi VisualNOS       guifg=#333333 guibg=#f18c96 gui=bold,underline
hi WarningMsg      guifg=#ffffff guibg=#333333 gui=bold
hi WildMenu        guibg=#2c302d guifg=#cbecd0 gui=underline

hi pythonSpaceError guibg=#f2f2f2
