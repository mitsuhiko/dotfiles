" Vim syntax file
" Language:     eruby/rhtml
" Maintainer:   Armin Ronacher <armin.ronacher@active-4.com>
" URL:          http://lucumr.pocoo.org/
" Last Change:  2007 April 2

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

if !exists("main_syntax")
  let main_syntax = "html"
endif

"Source the html syntax file
ru! syntax/html.vim
unlet b:current_syntax

"Put the ruby syntax file in @rubyTop
syn include @rubyTop syntax/ruby.vim

" Block rules
syn region erubyComment start="#" end="%>"
syn region erubyBlock matchgroup=erubyRubyDelim start=#<%=\?%\@!# end=#%># keepend containedin=ALL contains=erubyComment,@rubyTop
if exists("eruby_percent_processing")
  syn region erubyBlock matchgroup=erubyRubyDelim start=#^%%\@!# end=#$# keepend containedin=ALL contains=@rubyTop
endif

" Escapes
syn match erubyEscape "<%%"
syn match erubyEscape "%%>"
if exists("eruby_percent_processing")
  syn match erubyEscape +^%%+
endif

" Default highlighting links
hi link erubyRubyDelim todo
hi link erubyComment comment
hi link erubyEscape special

let b:current_syntax = "eruby"
