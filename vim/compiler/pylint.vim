" Vim compiler file for Python
" Compiler:     Style checking tool for Python
" Maintainer:   Alexander Timoshenko <gonzo@univ.kiev.ua>
" Last Change:  2006 Feb 08 by Tim Farley <tofarley@gmail.com>
"
" Installation:
"   Drop pylint.vim in ~/.vim/compiler
"   Ensure that your PATH environment variable includes the path to pylint
"   Add the following lines to the autocmd section of your .vimrc
"	autocmd FileType python compiler pylint
"	autocmd BufReadPost quickfix map <buffer> <silent> <CR> :.cc <CR> :ccl
"   * The last line is optional. It will automatically close :cwindow after
"   you have selected an error using the return key. You can reopen the
"   :cwindow using the command :cw or you can use :cn :cp to cycle through
"   the next, and previous error/warning respectively. 
"
" Usage:
"   :make   - runs a standard vim make command using pylint as the compiler
"   :Pylint - executes a silent make and automatically opens a :cwindow
"	      where you can quickly traverse through the errors in your code.


if exists("current_compiler")
  finish
endif
let current_compiler = "pylint"

" We should echo filename because pylint trancates .py
" If someone know better way - let me know :) 
setlocal makeprg=(echo\ '[%]';\ pylint\ %)
" We could omit end of file-entry, there is only one file
setlocal efm=%+P[%f],%t:\ %#%l:%m

command Pylint :call Pylint()

function! Pylint()
    "setlocal sp=>%s\ 2>&1	" Output the results of make to a file (UNIX)
    "setlocal sp=>%s            " Output the results of make to a file (Win32)
    silent make
    cwindow
endfunction
