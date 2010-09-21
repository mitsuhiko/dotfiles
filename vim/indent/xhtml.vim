if exists('b:did_indent')
  finish
endif

let b:did_indent = 1

" [-- local settings (must come before aborting the script) --]
setlocal indentexpr=XmlIndentGet(v:lnum,0)
setlocal indentkeys=o,O,*<Return>,<>>,<<>,/,{,}

set cpo-=C

if !exists('b:xml_indent_open')
  let b:xml_indent_open = '.\{-}<\a'
  " pre tag, e.g. <address>
  " let b:xml_indent_open = '.\{-}<[/]\@!\(address\)\@!'
endif

if !exists('b:xml_indent_close')
  let b:xml_indent_close = '.\{-}</'
  " end pre tag, e.g. </address>
  " let b:xml_indent_close = '.\{-}</\(address\)\@!'
endif

" [-- finish, if the function already exists --]
if exists('*XmlIndentGet') | finish | endif

fun! <SID>XmlIndentWithPattern(line, pat)
  let s = substitute('x'.a:line, a:pat, "\1", 'g')
  return strlen(substitute(s, "[^\1].*$", '', ''))
endfun

" [-- check if it's xml --]
fun! <SID>XmlIndentSynCheck(lnum)
  if '' != &syntax
    let syn1 = synIDattr(synID(a:lnum, 1, 1), 'name')
    let syn2 = synIDattr(synID(a:lnum, strlen(getline(a:lnum)) - 1, 1), 'name')
    if '' != syn1 && syn1 !~ 'xml' && '' != syn2 && syn2 !~ 'xml'
      " don't indent pure non-xml code
      return 0
    endif
  endif
  return 1
endfun

fun! XmlIndentGet(cur_lnum, use_syntax_check)
  " Find a non-empty line above the current line.
  let cur_lnum = a:cur_lnum
  let cur_line = getline(cur_lnum)
  let prev_lnum = prevnonblank(cur_lnum - 1)
  let prev_line = getline(prev_lnum)

  " Hit the start of the file, use zero indent.
  if prev_lnum == 0
    return 0
  endif

"  if a:use_syntax_check
"    if 0 == <SID>XmlIndentSynCheck(prev_lnum) || 0 == <SID>XmlIndentSynCheck(a:lnum)
"      return indent(a:lnum)
"    endif
"  endif

  let ind = indent(prev_lnum)

  if match(prev_line, '^\s*</') == -1 " prev_line is not </end>, increase ind
    let xx = match(prev_line, '^\s*<[^ >]\+\s\+\zs\w.*[^>]$')
    if xx >= 0
      let ind =  xx
    elseif match(prev_line, '^\s*<%--') == 0
          \ && match(prev_line, '--%>$') == -1
      let ind = ind + 5
    elseif match(prev_line, '^\s*<!--') == 0
          \ && match(prev_line, '-->$') == -1
      let ind = ind + 5
    elseif match(prev_line, '-->$') >= 0
      " if prev_line is the end of comment, align to the beginning of comment
      let slnum = prev_lnum
      while match(getline(slnum), '^\s*<!--') < 0
        let slnum = slnum - 1
      endwhile
      let ind = indent(slnum)
    elseif match(prev_line, '--%>$') >= 0
      " if prev_line is the end of comment, align to the beginning of comment
      let slnum = prev_lnum
      while match(getline(slnum), '^\s*<%--') < 0
        let slnum = slnum - 1
      endwhile
      let ind = indent(slnum)
    elseif match(prev_line, '^\s*[a-zA-Z]\S\+=.*>$') == 0
          \ || match(prev_line, '^\s*".*">$') == 0
      " if prev_line is end of multi-line tag,
      let slnum = prev_lnum
      while indent(slnum) >= ind
        let slnum = slnum - 1
      endwhile
      if match(prev_line, '/>$') >= 0
        " align to beginning of tag if it's closed.
        let ind = indent(slnum)
      elseif match(getline(slnum), '^\s*<!DOCTYPE') == 0
        " align to beginning of DOCTYPE tag
        let ind = indent(slnum)
      else
        " align to beginning of tag + sw
        let ind = indent(slnum) + &sw
      endif
    else
      let ind = (&sw *
            \  (<SID>XmlIndentWithPattern(prev_line, b:xml_indent_open)
            \ - <SID>XmlIndentWithPattern(prev_line, b:xml_indent_close)
            \ - <SID>XmlIndentWithPattern(prev_line, '.\{-}/>'))) + ind
    endif
  else
    let ind = ind " prev_line is </end>, keep indent
  endif

  if match(cur_line, '^\s*</') == 0
    " cur_line is </end>, decrease ind
    let ind = (&sw *
          \  (<SID>XmlIndentWithPattern(cur_line, b:xml_indent_open)
          \ - <SID>XmlIndentWithPattern(cur_line, b:xml_indent_close)
          \ - <SID>XmlIndentWithPattern(cur_line, '.\{-}/>'))) + ind
  endif

  return ind
endfun

" vim:ts=8
