"-------------------------------------------------------------------------------
"  Description: My personal colors
"          $Id: martin_krischik.vim 214 2006-05-25 09:24:57Z krischik $
"    Copyright: Copyright (C) 2006 Martin Krischik
"   Maintainer:	Martin Krischik 
"      $Author: krischik $
"        $Date: 2006-05-25 11:24:57 +0200 (Do, 25 Mai 2006) $
"      Version: 1.1 
"    $Revision: 214 $
"     $HeadURL: https://svn.sourceforge.net/svnroot/gnuada/trunk/tools/vim/colors/martin_krischik.vim $
"	  Note:	Tried and Tested for 'builtin_gui', 'xterm' (KDE Konsole)
"		'vt320'" (OpenVMS) and 'linux' (Linux Console).
"      History: 16.05.2006 MK Check that all vim 7.0 colors are set
"		16.05.2006 MK Split GUI from terminal.
"		24.05.2006 MK Unified Headers
"	 Usage: copy to colors directory
"------------------------------------------------------------------------------

" First remove all existing highlighting.

set background=light
highlight clear

if exists ("syntax_on")
    syntax reset
endif

let colors_name = "martin_krischik"

if (&term == "builtin_gui")

    " Set GUI colors.

    "---------- User-Interface Colors ----------------------------------------
    "
    " Normal Text Colors
    "
    highlight Normal		gui=none		guifg=black	    guibg=white
    highlight Search							    guibg=Yellow
    highlight SpecialKey				guifg=Blue
    highlight Title		gui=bold		guifg=Magenta
    highlight LineNr					guifg=Brown	    guibg=grey80
    highlight NonText		gui=bold		guifg=Blue	    guibg=grey80
    highlight MatchParen						    guibg=Cyan
    highlight IncSearch		gui=reverse
    "
    " Messages
    "
    highlight WarningMsg				guifg=Red
    highlight ErrorMsg					guifg=White	    guibg=Red
    highlight ModeMsg		gui=bold
    highlight MoreMsg		gui=bold		guifg=SeaGreen
    highlight Question		gui=bold		guifg=SeaGreen
    "
    " Spell Checker
    "
    highlight SpellBad		gui=undercurl							guisp=Red
    highlight SpellCap		gui=undercurl							guisp=Blue
    highlight SpellLocal	gui=undercurl							guisp=DarkCyan
    highlight SpellRare		gui=undercurl							guisp=Magenta
    "
    " Status line
    "
    highlight StatusLine	gui=bold,reverse	guifg=LightBlue2    guibg=black
    highlight StatusLineNC	gui=reverse		guifg=grey75	    guibg=black
    highlight VertSplit		gui=reverse		guifg=LightBlue3    guibg=black
    "
    " Visual selektion
    "
    highlight Visual		gui=reverse		guifg=firebrick     guibg=white
    highlight VisualNOS		gui=reverse		guifg=firebrick     guibg=black
    "
    " tab pages line
    "
    highlight TabLine		gui=reverse		guifg=grey75	    guibg=black
    highlight TabLineFill	gui=reverse
    highlight TabLineSel	gui=bold,reverse	guifg=LightBlue2    guibg=black
    "
    " Menu colors
    "
    highlight Pmenu							    guibg=LightMagenta
    highlight PmenuSel							    guibg=Grey
    highlight PmenuSbar							    guibg=Grey
    highlight PmenuThumb	gui=reverse
    highlight WildMenu					guifg=Black	    guibg=Yellow
    "
    " Diff colors
    "
    highlight DiffAdd							    guibg=LightBlue
    highlight DiffChange						    guibg=LightMagenta
    highlight DiffDelete	gui=bold		guifg=Blue	    guibg=LightCyan
    highlight DiffText		gui=bold				    guibg=Red
    "
    " Fold colors
    "
    highlight FoldColumn				guifg=DarkBlue	    guibg=Grey
    highlight Folded					guifg=DarkBlue	    guibg=LightGrey
    "
    " Other Syntax Highlight Colors
    "
    highlight Directory		guifg=Blue
    highlight SignColumn	guifg=DarkBlue	    guibg=Grey
    " highlight Menu
    " highlight Scrollbar
    " highlight Tooltip

    "---------- Syntax Colors ------------------------------------------------
    "
    " Comment colors syntax-group
    "
    highlight Comment					guifg=grey30
    "
    " Constant colors group
    "
    highlight Boolean					guifg=DarkOrchid3   guibg=grey95
    highlight Character					guifg=RoyalBlue3    guibg=grey95
    highlight Constant					guifg=MediumOrchid3 guibg=grey95
    highlight Float					guifg=MediumOrchid4 guibg=grey95
    highlight Number					guifg=DarkOrchid4   guibg=grey95
    highlight String					guifg=RoyalBlue4    guibg=grey95
    "
    " Identifier colors group
    "
    highlight Function					guifg=SteelBlue
    highlight Identifier				guifg=DarkCyan
    "
    " Statement colors group
    "
    highlight Conditional	gui=bold		guifg=DodgerBlue4
    highlight Exception		gui=none		guifg=SlateBlue4
    highlight Keyword		gui=bold		guifg=RoyalBlue4
    highlight Label		gui=none		guifg=SlateBlue3
    highlight Operator		gui=none		guifg=RoyalBlue3
    highlight Repeat		gui=bold		guifg=DodgerBlue3
    highlight Statement		gui=none		guifg=RoyalBlue4
    "
    " Preprocessor colors group
    "
    highlight Define					guifg=brown4	    guibg=snow
    highlight Include					guifg=firebrick3    guibg=snow
    highlight Macro					guifg=brown3	    guibg=snow
    highlight PreCondit					guifg=red	    guibg=snow
    highlight PreProc					guifg=firebrick4    guibg=snow
    "
    " type group
    "
    highlight StorageClass	gui=none		guifg=SeaGreen3
    highlight Structure		gui=none		guifg=DarkSlateGray4
    highlight Type		gui=none		guifg=SeaGreen4
    highlight Typedef		gui=none		guifg=DarkSeaGreen4
    "
    " special symbol group
    "
    highlight Special					guifg=SlateBlue     guibg=GhostWhite
    highlight SpecialChar				guifg=DeepPink	    guibg=GhostWhite
    highlight Tag					guifg=DarkSlateBlue guibg=GhostWhite
    highlight Delimiter					guifg=DarkOrchid    guibg=GhostWhite
    highlight SpecialComment				guifg=VioletRed     guibg=GhostWhite
    highlight Debug					guifg=maroon	    guibg=GhostWhite
    "
    " text that stands out
    "
    highlight Underlined	gui=underline		guifg=SlateBlue
    "
    " left blank, hidden
    "
    highlight Ignore					guifg=bg
    "
    " any erroneous construct
    "
    highlight Error		gui=undercurl		guifg=Red	    guibg=MistyRose
    "
    " anything that needs extra attention
    "
    highlight Todo					guifg=Blue	    guibg=Yellow

    "---------- Cursor Colors ------------------------------------------------
    "
    " Mouse Cursor
    "
    highlight cCursor	     guifg=bg	 guibg=DarkRed
    highlight Cursor	     guifg=bg	 guibg=DarkGreen
    highlight CursorColumn		 guibg=FloralWhite
    highlight CursorIM	     guifg=bg	 guibg=DarkGrey
    highlight CursorLine		 guibg=cornsilk
    highlight lCursor	     guifg=bg	 guibg=DarkMagenta
    highlight oCursor	     guifg=bg	 guibg=DarkCyan
    highlight vCursor	     guifg=bg	 guibg=DarkYellow
    "
    " Text Cursor
    "
    set guicursor=n:block-lCursor,
		 \i:ver25-Cursor,
		 \r:hor25-Cursor,
		 \v:block-vCursor,
		\ve:ver35-vCursor,
		 \o:hor50-oCursor-blinkwait75-blinkoff50-blinkon75,
		 \c:block-cCursor,
		\ci:ver20-cCursor,
		\cr:hor20-cCursor,
		\sm:block-Cursor-blinkwait175-blinkoff150-blinkon175

    syntax enable

    finish
elseif	(&term == "xterm")  ||
      \ (&term == "vt320")  ||
      \ (&term == "linux")

    " Only set colors for terminals we actualy know of

    if &term=="vt320"
	set t_Co=8
    else
	set t_Co=16
    endif

    "---------- User-Interface Colors ----------------------------------------
    "
    " Normal Text Colors
    "
    highlight Normal		term=none	    cterm=none		    ctermfg=Black	ctermbg=LightGray
    highlight Search		term=reverse							ctermbg=DarkYellow
    highlight SpecialKey	term=bold				    ctermfg=DarkBlue	ctermbg=LightGray
    highlight Title		term=bold				    ctermfg=DarkMagenta	ctermbg=LightGray
    highlight LineNr		term=underline				    ctermfg=DarkRed	ctermbg=DarkGray
    highlight NonText		term=bold				    ctermfg=LightBlue	ctermbg=LightGray
    highlight MatchParen	term=reverse				    ctermbg=DarkYellow
    highlight IncSearch		term=reverse	    cterm=reverse
    "
    " Messages
    "
    highlight WarningMsg	term=standout				    ctermfg=DarkRed	ctermbg=LightGray
    highlight ErrorMsg		term=standout				    ctermfg=White	ctermbg=DarkRed
    highlight ModeMsg		term=bold	    cterm=bold					ctermbg=LightGray
    highlight MoreMsg		term=bold				    ctermfg=DarkGreen	ctermbg=LightGray
    highlight Question		term=standout				    ctermfg=DarkGreen	ctermbg=LightGray
    "
    " Spell Checker
    "
    highlight SpellBad		term=reverse							ctermbg=LightRed
    highlight SpellCap		term=reverse							ctermbg=LightBlue
    highlight SpellLocal	term=underline							ctermbg=LightCyan
    highlight SpellRare		term=reverse							ctermbg=LightMagenta
    "
    " Status line
    "
    highlight StatusLine	term=bold,reverse   cterm=bold,reverse
    highlight StatusLineNC	term=reverse	    cterm=reverse
    highlight VertSplit		term=reverse	    cterm=reverse
    "
    " Visual selektion
    "
    highlight Visual		term=reverse	    cterm=reverse	    ctermfg=DarkRed	ctermbg=LightGray
    highlight VisualNOS		term=bold,underline cterm=bold,underline
    "
    " tab pages line
    "
    highlight TabLine		term=reverse	    cterm=reverse
    highlight TabLineFill	term=reverse	    cterm=reverse
    highlight TabLineSel	term=bold,reverse   cterm=bold,reverse
    "
    " Menu colors
    "
    highlight Pmenu										ctermbg=DarkMagenta
    highlight PmenuSel										ctermbg=LightGray
    highlight PmenuSbar										ctermbg=LightGray
    highlight PmenuThumb			    cterm=reverse
    highlight WildMenu		term=standout				    ctermfg=Black	ctermbg=Yellow
    "
    " Diff colors
    "
    highlight DiffAdd		term=bold							ctermbg=LightBlue
    highlight DiffChange	term=bold							ctermbg=LightMagenta
    highlight DiffDelete	term=bold				    ctermfg=LightBlue	ctermbg=LightCyan
    highlight DiffText		term=reverse	    cterm=bold					ctermbg=LightRed
    "
    " Fold colors
    "
    highlight FoldColumn	term=standout				    ctermfg=DarkBlue	ctermbg=DarkGray
    highlight Folded		term=standout				    ctermfg=DarkBlue	ctermbg=DarkGray
    "
    " Other Syntax Highlight Colors
    "
    highlight Directory		term=bold				    ctermfg=DarkBlue	ctermbg=LightGray
    highlight SignColumn	term=standout				    ctermfg=DarkBlue	ctermbg=DarkGray
    " highlight Menu
    " highlight Scrollbar
    " highlight Tooltip

    "---------- Syntax Colors ------------------------------------------------
    "
    " Comment colors syntax-group
    "
    highlight Comment		term=bold				    ctermfg=DarkGray	ctermbg=LightGray
    "
    " Constant colors group
    "
    highlight Boolean		term=underline				    ctermfg=DarkRed	ctermbg=LightGray
    highlight Character		term=underline				    ctermfg=DarkRed	ctermbg=LightGray
    highlight Constant		term=underline				    ctermfg=DarkRed	ctermbg=LightGray
    highlight Float		term=underline				    ctermfg=DarkRed	ctermbg=LightGray
    highlight Number		term=underline				    ctermfg=DarkRed	ctermbg=LightGray
    highlight String		term=underline				    ctermfg=DarkRed	ctermbg=LightGray
    "
    " Identifier colors group
    "
    highlight Function		term=underline				    ctermfg=DarkCyan	ctermbg=LightGray
    highlight Identifier	term=underline				    ctermfg=DarkCyan	ctermbg=LightGray
    "
    " Statement colors group
    "
    highlight Conditional	term=bold				    ctermfg=DarkBlue	ctermbg=LightGray
    highlight Exception		term=bold				    ctermfg=DarkBlue	ctermbg=LightGray
    highlight Keyword		term=bold				    ctermfg=DarkBlue	ctermbg=LightGray
    highlight Label		term=bold				    ctermfg=DarkBlue	ctermbg=LightGray
    highlight Operator		term=bold				    ctermfg=DarkBlue	ctermbg=LightGray
    highlight Repeat		term=bold				    ctermfg=DarkBlue	ctermbg=LightGray
    highlight Statement		term=bold				    ctermfg=DarkBlue	ctermbg=LightGray
    "
    " Preprocessor colors group
    "
    highlight Define		term=underline				    ctermfg=DarkMagenta	ctermbg=LightGray
    highlight Include		term=underline				    ctermfg=DarkMagenta	ctermbg=LightGray
    highlight Macro		term=underline				    ctermfg=DarkMagenta	ctermbg=LightGray
    highlight PreCondit		term=underline				    ctermfg=DarkMagenta	ctermbg=LightGray
    highlight PreProc		term=underline				    ctermfg=DarkMagenta	ctermbg=LightGray
    "
    " type group
    "
    highlight StorageClass	term=underline				    ctermfg=DarkGreen	ctermbg=LightGray
    highlight Structure		term=underline				    ctermfg=DarkGreen	ctermbg=LightGray
    highlight Type		term=underline				    ctermfg=DarkGreen	ctermbg=LightGray
    highlight Typedef		term=underline				    ctermfg=DarkGreen	ctermbg=LightGray
    "
    " special symbol group
    "
    highlight Special		term=bold				    ctermfg=DarkMagenta	ctermbg=LightGray
    highlight SpecialChar	term=bold				    ctermfg=DarkMagenta	ctermbg=LightGray
    highlight Tag		term=bold				    ctermfg=DarkMagenta	ctermbg=LightGray
    highlight Delimiter		term=bold				    ctermfg=DarkMagenta	ctermbg=LightGray
    highlight SpecialComment	term=bold				    ctermfg=DarkMagenta	ctermbg=LightGray
    highlight Debug		term=bold				    ctermfg=DarkMagenta	ctermbg=LightGray
    "
    " text that stands out
    "
    highlight Underlined	term=underline	    cterm=underline	    ctermfg=DarkMagenta	ctermbg=LightGray
    "
    " left blank, hidden
    "
    highlight Ignore							    ctermfg=White	ctermbg=grey
    "
    " any erroneous construct
    "
    highlight Error		term=reverse				    ctermfg=White	ctermbg=LightRed
    "
    " anything that needs extra attention
    "
    highlight Todo		term=standout				    ctermfg=Black	ctermbg=Yellow

    "---------- Cursor Colors ------------------------------------------------
    "
    " Mouse Cursor
    "
    highlight Cursor				    ctermfg=bg		    ctermbg=DarkGreen
    highlight CursorColumn	term=reverse				    ctermbg=LightGray
    highlight CursorIM				    ctermfg=bg		    ctermbg=DarkGrey
    highlight CursorLine	term=reverse				    ctermbg=LightGray

    syntax enable

    finish
else

    " terminal is completely unknown - fallback to system default

    set t_Co=8

    finish
endif

"------------------------------------------------------------------------------
"   Copyright (C) 2006  Martin Krischik
"
"   This program is free software; you can redistribute it and/or
"   modify it under the terms of the GNU General Public License
"   as published by the Free Software Foundation; either version 2
"   of the License, or (at your option) any later version.
"   
"   This program is distributed in the hope that it will be useful,
"   but WITHOUT ANY WARRANTY; without even the implied warranty of
"   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"   GNU General Public License for more details.
"   
"   You should have received a copy of the GNU General Public License
"   along with this program; if not, write to the Free Software
"   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
"------------------------------------------------------------------------------
" vim: textwidth=0 nowrap tabstop=8 shiftwidth=4 softtabstop=4 noexpandtab
" vim: filetype=vim encoding=latin1 fileformat=unix
