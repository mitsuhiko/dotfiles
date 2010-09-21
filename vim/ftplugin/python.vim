" VIM filetype plugin
" Language: Python source files
" Maintainer: Sergei Matusevich <motus@motus.kiev.ua>
" ICQ: 31114346 Yahoo: motus2
" http://motus.kiev.ua/motus2/Files/py_jump.vim
" Last Change: 2 November 2005
" Licence: Public Domain

" WHAT'S COOL: Use % command when editing python sources
" to jump to the end of the indented block and then back.
" If cursor is at the bracket character, % will take
" you to the matching bracket.

" INSTALLATION: rename this file to python.vim
" and copy it to your ~/.vim/ftplugin/ directory

if exists("g:did_python_ftplugin")
  finish
endif

" Don't load another plugin (this is global)
let g:did_python_ftplugin = 1

" This is the only tunable parameter of this script.
" It specifies timeout (in seconds) for the backward jump.
" That is, if you used % twice within this time frame,
" it will jump back, not forward, thus trying to guess
" correct indentation level. Try to use % several times
" to check it out.
let g:py_jump_timeout = 1

let s:py_jump_ts = 0

if !exists("*PyJump")

  function s:PySeekForward()
    let line    = line(".") + 1
    let lnEnd   = line("$")
    let iStart  = indent(".")
    while line <= lnEnd
      let iCurr = indent(line)
      if iCurr <= iStart && getline(line) !~ "^\\s\*$"
        let line = prevnonblank(line - 1)
        call cursor(line, indent(line) + 1)
        return
      endif
      let line = line + 1
    endwhile
    let line = prevnonblank("$")
    call cursor(line, indent(line) + 1)
  endfunction

  function s:PySeekBackward()
    let line    = prevnonblank(".")
    let iStart  = indent(line)
    while line > 0
      let iCurr = indent(line)
      if iCurr < iStart && getline(line) !~ "^\\s\*$"
        call cursor(line, indent(line) + 1)
        return 0
      endif
      let line = line - 1
    endwhile
    return 1
  endfunction

  function PyJump(vis_mode)
    let ch = getline(".")[col(".")-1]
    if ch != "," && ch != ":" && stridx(&matchpairs, ch) >= 0
      let s:py_jump_ts = 0
      unmap <buffer> %
      normal %
      nnoremap <buffer> % :call PyJump("")<Enter>
      vnoremap <buffer> % omao<Esc>:call PyJump(visualmode())<Enter>
    else
      let ts = localtime()
      let ts_fwd = ts - s:py_jump_ts >= g:py_jump_timeout
      let line = prevnonblank(".")
      let next = nextnonblank(line+1)
      if indent(line) < indent(next) && ts_fwd
        call s:PySeekForward()
      else
        if s:PySeekBackward()
          call s:PySeekForward()
        endif
      endif
      let s:py_jump_ts = ts
    endif
    if strlen(a:vis_mode)
      exec "normal " . a:vis_mode . "`ao"
    endif
  endfunction

endif

nnoremap <buffer> % :call PyJump("")<Enter>
vnoremap <buffer> % omao<Esc>:call PyJump(visualmode())<Enter>

