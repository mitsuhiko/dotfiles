" yankring.vim - Yank / Delete Ring for Vim
" ---------------------------------------------------------------
" Version:  3.0
" Authors:  David Fishburn <fishburn@ianywhere.com>
" Last Modified: Fri 07 Sep 2007 11:20:49 PM Eastern Daylight Time
" Script:   http://www.vim.org/scripts/script.php?script_id=1234
" Based On: Mocked up version by Yegappan Lakshmanan
"           http://groups.yahoo.com/group/vim/post?act=reply&messageNum=34406
"  License: GPL (Gnu Public License)
" GetLatestVimScripts: 1234 1 :AutoInstall: yankring.vim
"
" Perl integration with the clipboard:
"     http://www.xav.com/perl/site/lib/Win32/Clipboard.html
"

if exists('loaded_yankring') || &cp
    finish
endif

if v:version < 700
  echomsg 'yankring: You need at least Vim 7.0'
  finish
endif

let loaded_yankring = 30

" Allow the user to override the # of yanks/deletes recorded
if !exists('g:yankring_max_history')
    let g:yankring_max_history = 100
elseif g:yankring_max_history < 0
    let g:yankring_max_history = 100
endif

" Allow the user to specify if the plugin is enabled or not
if !exists('g:yankring_enabled')
    let g:yankring_enabled = 1
endif

" Specify a separation character for the key maps
if !exists('g:yankring_separator')
    let g:yankring_separator = ','
endif

" Specify max display length for each element for YRShow
if !exists('g:yankring_max_display')
    let g:yankring_max_display = 0
endif

" Check if yankring should persist between Vim instances
if !exists('g:yankring_persist')
    let g:yankring_persist = 1
endif

" Specify whether the results of the ring should be displayed
" in a separate buffer window instead of the use of echo
if !exists('g:yankring_window_use_separate')
    let g:yankring_window_use_separate = 1
endif

" Specifies whether the window is closed after an action
" is performed
if !exists('g:yankring_window_auto_close')
    let g:yankring_window_auto_close = 1
endif

" When displaying the buffer, how many lines should it be
if !exists('g:yankring_window_height')
    let g:yankring_window_height = 8
endif

" When displaying the buffer, how many lines should it be
if !exists('g:yankring_window_width')
    let g:yankring_window_width = 30
endif

" When displaying the buffer, where it should be placed
if !exists('g:yankring_window_use_horiz')
    let g:yankring_window_use_horiz = 1
endif

" When displaying the buffer, where it should be placed
if !exists('g:yankring_window_use_bottom')
    let g:yankring_window_use_bottom = 1
endif

" When displaying the buffer, where it should be placed
if !exists('g:yankring_window_use_right')
    let g:yankring_window_use_right = 1
endif

" If the user presses <space>, toggle the width of the window
if !exists('g:yankring_window_increment')
    let g:yankring_window_increment = 50
endif

" Controls whether the . operator will repeat yank operations
" The default is based on cpoptions: |cpo-y|
"	y	A yank command can be redone with ".".
if !exists('g:yankring_dot_repeat_yank')
    let g:yankring_dot_repeat_yank = (&cpoptions=~'y'?1:0)
endif

" Only adds unique items to the yankring.
" If the item already exists, that element is set as the
" top of the yankring.
if !exists('g:yankring_ignore_duplicate')
    let g:yankring_ignore_duplicate = 1
endif

" Vim automatically manages the numbered registers:
" 0   - last yanked text
" 1-9 - last deleted items
" If this option is turned on, the yankring will manage the 
" values in them.
if !exists('g:yankring_manage_numbered_reg')
    let g:yankring_manage_numbered_reg = 0
endif

" Allow the user to specify what characters to use for the mappings.
if !exists('g:yankring_n_keys')
    let g:yankring_n_keys = 'x,yy,dd,yw,dw,ye,de,yE,dE,yiw,diw,yaw,daw,y$,d$,Y,D,yG,dG,ygg,dgg'
endif

" Whether we sould map the . operator
if !exists('g:yankring_map_dot')
    let g:yankring_map_dot = 1
endif

" Whether we sould map the "g" paste operators
if !exists('g:yankring_paste_using_g')
    let g:yankring_paste_using_g = 1
endif

if !exists('g:yankring_v_key')
    let g:yankring_v_key = 'y'
endif

if !exists('g:yankring_del_v_key')
    let g:yankring_del_v_key = 'd'
endif

if !exists('g:yankring_paste_n_bkey')
    let g:yankring_paste_n_bkey = 'P'
endif

if !exists('g:yankring_paste_n_akey')
    let g:yankring_paste_n_akey = 'p'
endif

if !exists('g:yankring_paste_v_bkey')
    let g:yankring_paste_v_bkey = 'P'
endif

if !exists('g:yankring_paste_v_akey')
    let g:yankring_paste_v_akey = 'p'
endif

if !exists('g:yankring_replace_n_pkey')
    let g:yankring_replace_n_pkey = '<C-P>'
endif

if !exists('g:yankring_replace_n_nkey')
    let g:yankring_replace_n_nkey = '<C-N>'
endif

" Script variables for the yankring buffer
let s:yr_buffer_name       = '__YankRing__'
let s:yr_buffer_last_winnr = -1
let s:yr_buffer_last       = -1
let s:yr_buffer_id         = -1
let s:yr_elements          = []
let s:yr_element_type      = []
let s:yr_search            = ""

" Vim window size is changed by the yankring plugin or not
let s:yankring_winsize_chgd = 0

" If the we are persisting the yankring between Vim instances
" set the scope to be global instead of script level.
let s:yr_scope = (g:yankring_persist==1?'g':'s')

" Enables or disables the yankring 
function! s:YRToggle(...)
    " Default the current state to toggle
    let new_state = ((g:yankring_enabled == 1) ? 0 : 1)

    " Allow the user to specify if enabled
    if a:0 > 0
        let new_state = ((a:1 == 1) ? 1 : 0)
    endif
            
    " YRToggle accepts an integer value to specify the state
    if new_state == g:yankring_enabled 
        return
    elseif new_state == 1
        call YRMapsCreate()
    else
        call YRMapsDelete()
    endif
endfunction
 

" Enables or disables the yankring 
function! s:YRDisplayElem(disp_nbr, script_var) 
    if g:yankring_max_display == 0
        if g:yankring_window_use_separate == 1
            let max_display = 500
        else
            let max_display = g:yankring_window_width + 
                        \ g:yankring_window_increment - 
                        \ 12
        endif
    else
        let max_display = g:yankring_max_display
    endif

    if exists(s:yr_scope.':YR_ELEM_'.a:script_var)
        let length = strlen({s:yr_scope}:YR_ELEM_{a:script_var})
        " Fancy trick to align them all regardless of how many
        " digits the element # is
        return a:disp_nbr.
                    \ strtrans(
                    \ strpart("      ",0,(6-strlen(a:disp_nbr+1))).
                    \ (
                    \ (length>max_display)?
                    \ (strpart({s:yr_scope}:YR_ELEM_{a:script_var},0,max_display).
                    \ '...'):
                    \ ({s:yr_scope}:YR_ELEM_{a:script_var})
                    \ )
                    \ )
    endif
    return ""
endfunction
 

" Enables or disables the yankring 
function! s:YRShow(...) 
    " If no parameter was provided assume the user wants to 
    " toggle the display.
    let toggle = 1
    if a:0 > 0
        let toggle = matchstr(a:1, '\d\+')
    endif

    if toggle == 1
        if bufwinnr(s:yr_buffer_id) > -1
            exec bufwinnr(s:yr_buffer_id) . "wincmd w"
            hide
            return
        endif
    endif

    " Reset the search string, since this is automatically called
    " if the yankring window is open.  A previous search must be
    " cleared since we do not want to show new items.  The user can
    " always run the search again.
    let s:yr_search = ""

    " List is shown in order of replacement
    " assuming using previous yanks
    let output = "--- YankRing ---\n"
    let output = output . "Elem  Content\n"

    let disp_item_nr = 1
    for elem in s:yr_elements
        let output  = output . s:YRDisplayElem(disp_item_nr, elem) . "\n"
        let disp_item_nr   += 1
    endfor

    if g:yankring_window_use_separate == 1
        call s:YRWindowOpen(output)
    else 
        echo output
    endif
endfunction
 

" Paste a certain item from the yankring
" If no parameter is provided, this function becomes interactive.  It will
" display the list (using YRShow) and allow the user to choose an element.
function! s:YRGetElem(...) 
    if s:yr_count == 0
        call s:YRWarningMsg('YR: yankring is empty')
        return -1
    endif

    let default_buffer = ((&clipboard=='unnamed')?'*':'"')

    let direction = 'p'
    if a:0 > 1
        " If the user indicated to paste above or below
        " let direction = ((a:2 ==# 'P') ? 'P' : 'p')
        if a:2 =~ '\(p\|gp\|P\|gP\)'
            let direction = a:2
        endif
    endif

    " Check to see if a specific value has been provided
    let elem = 0
    if a:0 > 0
        " Ensure we get only the numeric value (trim it)
        let elem = matchstr(a:1, '\d\+')
    else
        " If no parameter was supplied display the yankring
        " and prompt the user to enter the value they want pasted.
        call s:YRShow(0)

        if g:yankring_window_use_separate == 1
            " The window buffer is used instead of command line
            return
        endif

        let elem = input("Enter # to paste:")

        " Ensure we get only the numeric value (trim it)
        let elem = matchstr(elem, '\d\+')

        if elem == ''
            " They most likely pressed enter without entering a value
            return
        endif
    endif

    if elem < 1 || elem > s:yr_count
        call s:YRWarningMsg("YR: Invalid choice:".elem)
        return -1
    endif

    if !exists(s:yr_scope.':YR_ELEM_'.elem)
        call s:YRWarningMsg("YR: Elem:".elem." does not exist")
        return -1
    endif

    let default_buffer = ((&clipboard=='unnamed')?'*':'"')
    " let save_reg = getreg(default_buffer)
    " let save_reg_type = getregtype(default_buffer)
    call setreg(default_buffer
                \ , s:YRGetValElemNbr((elem-1), 'v')
                \ , s:YRGetValElemNbr((elem-1), 't')
                \ )
    exec "normal! ".direction
    " call setreg(default_buffer, save_reg, save_reg_type)

    " Set the previous action as a paste in case the user
    " press . to repeat
    call s:YRSetPrevOP('p', '', default_buffer)

endfunction
 

" Starting the top of the ring it will paste x items from it
function! s:YRGetMultiple(reverse_order, ...) 
    if s:yr_count == 0
        call s:YRWarningMsg('YR: yankring is empty')
        return
    endif

    " If the user provided a range, exit after that many
    " have been displayed
    let iter = 0
    let elem = 0
    if a:0 > 0
        " If no yank command has been supplied, assume it is
        " a full line yank
        let iter = matchstr(a:1, '\d\+')
    endif
    if a:0 > 1
        " If no yank command has been supplied, assume it is
        " a full line yank
        let elem = matchstr(a:2, '\d\+')
    endif
    if iter < 1 
        " The default to only 1 item if no argument is specified
        let iter = 1
    endif
    if iter > s:yr_count
        " Default to all items if they specified a very high value
        let iter = s:yr_count
    endif
    if elem < 1 || elem > s:yr_count
        " The default to only 1 item if no argument is specified
        let elem = 1
    endif

    " Base the increment on the sort order of the results
    let increment = ((a:reverse_order==0)?(1):(-1))

    if a:reverse_order != 0
        " If there are 5 elements in the ring
        " User wants the top 3 in reverse order
        " We need to set the starting element to 3, because 3,4,5
        " Starting at the current element 5, we need to:
        " 1 + (3 * -1 * 1)
        " 1 + (-3)
        " -2
        " So start 2 elements below the current position
        let elem = s:YRGetNextElem(elem, ((iter*-1*increment)-1) )
    endif

    while iter > 0
        " Paste the first item, and move on to the next.
        " digits the element # is
        call s:YRGetElem(elem)
        let elem = s:YRGetNextElem(elem, increment)
        let iter = iter - 1
    endwhile
endfunction
 

" Given a regular expression, check each element within
" the yankring, display only the matching items and prompt
" the user for which item to paste
function! s:YRSearch(...) 
    if s:yr_count == 0
        call s:YRWarningMsg('YR: yankring is empty')
        return
    endif

    let s:yr_search = ""
    " If the user provided a range, exit after that many
    " have been displayed
    if a:0 == 0 || (a:0 == 1 && a:1 == "")
        let s:yr_search = input('Enter [optional] regex:')
    else
        let s:yr_search = a:1
    endif

    if s:yr_search == ""
        " Show the entire yankring
        call s:YRShow(0)
        return
    endif

    let disp_item_nr = 1

    " List is shown in order of replacement
    " assuming using previous yanks
    let output        = "--- YankRing ---\n"
    let output        = output . "Elem  Content\n"
    let search_result = ""
    let valid_choices = ','

    for elem in s:yr_elements
        let v:errmsg = ''
        if exists(s:yr_scope.':YR_ELEM_'.elem)
            if match({s:yr_scope}:YR_ELEM_{elem}, s:yr_search) > -1
                let search_result = search_result . s:YRDisplayElem(disp_item_nr, elem) . "\n"
                let valid_choices = valid_choices . disp_item_nr . ','
            endif
            if v:errmsg != ''
                " If an error is report due to the regular expression
                " abort the checks
                return -1
            endif
        endif
        let disp_item_nr += 1
    endfor

    if search_result == ""
        let output = output . "Search for [".s:yr_search."] did not match any items "
    else
        let output = output . search_result
    endif

    if g:yankring_window_use_separate == 1
        call s:YRWindowOpen(output)
    else
        if valid_choices != ','
            let elem = input("Enter # to paste:")

            " Ensure we get only the numeric value (trim it)
            let elem = matchstr(elem, '\d\+')

            if elem == ''
                " They most likely pressed enter without entering a value
                return
            endif

            if valid_choices =~ ','.elem.','
                exec 'YRGetElem ' . elem
            else
                " User did not choose one of the elements that were found
                " Remove leading ,
                call s:YRWarningMsg( "YR: Only valid choices are:" .
                            \ strpart(valid_choices, 1)
                            \ )
                return -1
            endif

        else
            call s:YRWarningMsg( "YR: The pattern [" .
                        \ s:yr_search .
                        \ "] does not match any items in the yankring"
                        \ )
        endif
    endif

endfunction
 

" Resets the common script variables for managing the ring.
function! s:YRReset()
    let s:yr_next_idx              = 0
    let s:yr_last_paste_idx        = 0
    let s:yr_count                 = 0
    let s:yr_paste_dir             = 'p'

    " For the . op support
    let s:yr_prev_op_code          = ''
    let s:yr_prev_count            = ''
    let s:yr_prev_reg              = ''
    let s:yr_prev_reg_unnamed      = ''
    let s:yr_prev_reg_small        = ''
    let s:yr_prev_reg_insert       = ''
    let s:yr_prev_reg_expres       = ''
    let s:yr_prev_vis_lstart       = 0
    let s:yr_prev_vis_lend         = 0
    let s:yr_prev_vis_cstart       = 0
    let s:yr_prev_vis_cend         = 0

    " This is used to determine if the visual selection should be
    " reset prior to issuing the YRReplace
    let s:yr_prev_vis_mode         = 0
endfunction
 

" Clears the yankring by simply setting the # of items in it to 0.
" There is no need physically unlet each variable.
function! s:YRInit()
    call s:YRReset()

    " This is the MRU list of items in the yankring
    if !exists( s:yr_scope.':YR_ELEM_ORDER' )
        let {s:yr_scope}:YR_ELEM_ORDER = ""
    endif
    call s:YRMRUInit( 's:yr_elements', g:yankring_max_history, {s:yr_scope}:YR_ELEM_ORDER )

    let s:yr_count    = s:YRMRUSize('s:yr_elements')

    " We can potentially keep creating new global variables forever
    " since as the rings rotates through values, it will always be
    " increasing.  Add some additional logic to:
    "    a) Check for the current highest value in the ring
    "       by sorting the list and adding 1
    "    b) If the lowest value is larger than g:yankring_max_history, 
    "       set the next index item to be 1.
    if !empty(s:yr_elements)
        let sorted_mru    = sort(copy(s:yr_elements))
        let s:yr_next_idx = get(sorted_mru, -1) + 1

        if get(sorted_mru, 1) > g:yankring_max_history
            let s:yr_next_idx = 0
        endif
    endif
endfunction
 

" Clears the yankring by simply setting the # of items in it to 0.
" There is no need physically unlet each variable.
function! s:YRClear()
    call s:YRReset()

    " This is the MRU list of items in the yankring
    call s:YRMRUReset( 's:yr_elements' )
endfunction
 

" Determine which register the user wants to use
" For example the 'a' register:  "ayy
function! s:YRRegister()
    let user_register = v:register
    if &clipboard == 'unnamed' && user_register == '"'
        let user_register = '*'
    endif
    return user_register
endfunction


" Allows you to push a new item on the yankring.  Useful if something
" is in the clipboard and you want to add it to the yankring.
" Or if you yank something that is not mapped.
function! s:YRPush(...) 
    let user_register = s:YRRegister()

    if a:0 > 0
        " If no yank command has been supplied, assume it is
        " a full line yank
        let user_register = ((a:1 == '') ? user_register : a:1)
    endif

    " If we are pushing something on to the yankring, add it to
    " the default buffer as well so the next item pasted will
    " be the item pushed
    let default_buffer = ((&clipboard=='unnamed')?'*':'"')
    call setreg(default_buffer, getreg(user_register), 
                \ getregtype(user_register))

    call s:YRSetPrevOP('', '', '')
    call s:YRRecord(user_register)
endfunction


" Allows you to pop off any element from the yankring.
" If no parameters are provided the first element is removed.
" If a vcount is provided, that many elements are removed 
" from the top.
function! s:YRPop(...)
    if s:yr_count == 0
        call s:YRWarningMsg('YR: yankring is empty')
        return
    endif

    let v_count = 1
    if a:0 > 1 
        let v_count = a:2
    endif

    " If the user provided a parameter, remove that element 
    " from the yankring.  
    " If no parameter was provided assume the first element.
    let elem = 1
    if a:0 > 0
        " Get the element # from the parameter
        let elem = matchstr(a:1, '\d\+')
    endif
    
    " If the user entered a count, then remove that many
    " elements from the ring.
    while v_count > 0 
        call s:YRMRUDel('s:yr_elements', elem)
        let v_count = v_count - 1
    endwhile

    " If the yankring window is open, refresh it
    call s:YRWindowUpdate()
endfunction


" Adds this value to the yankring.
function! s:YRRecord(value) 

    " Add item to list
    " This will also account for duplicates.
    call s:YRMRUAdd( 's:yr_elements'
                \ , getreg(a:value)
                \ , getregtype(a:value) 
                \ )

    " If the yankring window is open, refresh it
    call s:YRWindowUpdate()

    " Manage the numbered registers
    if g:yankring_manage_numbered_reg == 1
        call s:YRSetNumberedReg()
    endif
endfunction


" Record the operation for the dot operator
function! s:YRSetPrevOP(op_code, count, reg) 
    let s:yr_prev_op_code     = a:op_code
    let s:yr_prev_count       = a:count
    let s:yr_prev_reg         = a:reg
    let s:yr_prev_reg_unnamed = getreg('"')
    let s:yr_prev_reg_small   = getreg('-')
    let s:yr_prev_reg_insert  = getreg('.')
    let s:yr_prev_vis_lstart  = line("'<")
    let s:yr_prev_vis_lend    = line("'>")
    let s:yr_prev_vis_cstart  = col("'<")
    let s:yr_prev_vis_cend    = col("'>")
    let s:yr_prev_chg_lstart  = line("'[")
    let s:yr_prev_chg_lend    = line("']")
    let s:yr_prev_chg_cstart  = col("'[")
    let s:yr_prev_chg_cend    = col("']")
    let s:yr_prev_reg_expres  = histget('=', -1)

    " If storing the last change position (using '[, '])
    " is not good enough, then another option is to:
    " Use :redir on the :changes command
    " and grab the last item.  Store this value
    " and compare it is YRDoRepeat.
    "
endfunction


" Adds this value to the yankring.
function! s:YRDoRepeat() 
    let dorepeat = 0

    if g:yankring_manage_numbered_reg == 1
        " When resetting the numbered register we are
        " must ignore the comparision of the " register.
        if s:yr_prev_reg_small  == getreg('-') &&
                    \ s:yr_prev_reg_insert == getreg('.') &&
                    \ s:yr_prev_reg_expres == histget('=', -1) &&
                    \ s:yr_prev_vis_lstart == line("'<") &&
                    \ s:yr_prev_vis_lend   == line("'>") &&
                    \ s:yr_prev_vis_cstart == col("'<") &&
                    \ s:yr_prev_vis_cend   == col("'>") &&
                    \ s:yr_prev_chg_lstart == line("'[") &&
                    \ s:yr_prev_chg_lend   == line("']") &&
                    \ s:yr_prev_chg_cstart == col("'[") &&
                    \ s:yr_prev_chg_cend   == col("']") 
            let dorepeat = 1
        endif
    else
        " Check the previously recorded value of the registers
        " if they are the same, we need to reissue the previous
        " yankring command.
        " If any are different, the user performed a command
        " command that did not involve the yankring, therefore
        " we should just issue the standard "normal! ." to repeat it.
        if s:yr_prev_reg_unnamed == getreg('"') &&
                    \ s:yr_prev_reg_small  == getreg('-') &&
                    \ s:yr_prev_reg_insert == getreg('.') &&
                    \ s:yr_prev_reg_expres == histget('=', -1) &&
                    \ s:yr_prev_vis_lstart == line("'<") &&
                    \ s:yr_prev_vis_lend   == line("'>") &&
                    \ s:yr_prev_vis_cstart == col("'<") &&
                    \ s:yr_prev_vis_cend   == col("'>") &&
                    \ s:yr_prev_chg_lstart == line("'[") &&
                    \ s:yr_prev_chg_lend   == line("']") &&
                    \ s:yr_prev_chg_cstart == col("'[") &&
                    \ s:yr_prev_chg_cend   == col("']") 
            let dorepeat = 1
        endif
    endif
    " If we are going to repeat check to see if the
    " previous command was a yank operation.  If so determine
    " if yank operations are allowed to be repeated.
    if dorepeat == 1 && s:yr_prev_op_code =~ '^y'
        " This value be default is set based on cpoptions.
        if g:yankring_dot_repeat_yank == 0
            let dorepeat = 0
        endif
    endif
    return dorepeat
endfunction


" Manages the Vim's numbered registers
function! s:YRSetNumberedReg() 

    let i = 1

    while i <= 10
        if i > s:yr_count
            break
        endif

        call setreg( (i-1)
                    \ , s:YRGetValElemNbr((i-1),'v')
                    \ , s:YRGetValElemNbr((i-1),'t')
                    \ )
        let i += 1
    endwhile
endfunction


" This internal function will add and subtract values from a starting
" point and return the correct element number.  It takes into account
" the circular nature of the yankring.
function! s:YRGetNextElem(start, iter) 

    let needed_elem = a:start + a:iter

    " The yankring is a ring, so if an element is
    " requested beyond the number of elements, we
    " must wrap around the ring.
    if needed_elem > s:yr_count
        let needed_elem = needed_elem % s:yr_count
    endif

    if needed_elem == 0
        " Can happen at the end or beginning of the ring
        if a:iter == -1
            " Wrap to the bottom of the ring
            let needed_elem = s:yr_count
        else
            " Wrap to the top of the ring
            let needed_elem = 1
        endif
    elseif needed_elem < 1
        " As we step backwards through the ring we could ask for a negative
        " value, this will wrap it around to the end
        let needed_elem = s:yr_count
    endif

    return needed_elem

endfunction


" Lets Vim natively perform the operation and then stores what
" was yanked (or deleted) into the yankring.
" Supports this for example -   5"ayy
function! s:YRYankCount(...) range

    let user_register = s:YRRegister()
    let v_count = v:count

    " Default yank command to the entire line
    let op_code = 'yy'
    if a:0 > 0
        " If no yank command has been supplied, assume it is
        " a full line yank
        let op_code = ((a:1 == '') ? op_code : a:1)
    endif

    if op_code == '.'
        if s:YRDoRepeat() == 1
            if s:yr_prev_op_code != ''
                let op_code       = s:yr_prev_op_code
                let v_count       = s:yr_prev_count
                let user_register = s:yr_prev_reg
            endif
        else
            exec "normal! ."
            return
        endif
    endif

    " Supports this for example -   5"ayy
    " A delete operation will still place the items in the
    " default registers as well as the named register
    exec "normal! ".
                \ ((v_count > 0)?(v_count):'').
                \ (user_register=='"'?'':'"'.user_register).
                \ op_code

    if user_register == '_'
        " Black hole register, ignore
        return
    endif
    
    call s:YRSetPrevOP(op_code, v_count, user_register)

    call s:YRRecord(user_register)
endfunction
 

" Handles ranges.  There are visual ranges and command line ranges.
" Visual ranges are easy, since we pass through and let Vim deal
" with those directly.
" Command line ranges means we must yank the entire line, and not
" just a portion of it.
function! s:YRYankRange(do_delete_selection, ...) range

    let user_register  = s:YRRegister()
    let default_buffer = ((&clipboard=='unnamed')?'*':'"')

    " Default command mode to normal mode 'n'
    let cmd_mode = 'n'
    if a:0 > 0
        " Change to visual mode, if command executed via
        " a visual map
        let cmd_mode = ((a:1 == 'v') ? 'v' : 'n')
    endif

    if cmd_mode == 'v' 
        " We are yanking either an entire line, or a range 
        exec "normal! gv".
                    \ (user_register==default_buffer?'':'"'.user_register).
                    \ 'y'
        if a:do_delete_selection == 1
            exec "normal! gv".
                        \ (user_register==default_buffer?'':'"'.user_register).
                        \ 'd'
        endif
    else
        " In normal mode, always yank the complete line, since this
        " command is for a range.  YRYankCount is used for parts
        " of a single line
        if a:do_delete_selection == 1
            exec a:firstline . ',' . a:lastline . 'delete '.user_register
        else
            exec a:firstline . ',' . a:lastline . 'yank ' . user_register
        endif
    endif

    if user_register == '_'
        " Black hole register, ignore
        return
    endif
    
    call s:YRSetPrevOP('', '', user_register)
    call s:YRRecord(user_register)
endfunction
 

" Paste from either the yankring or from a specified register
" Optionally a count can be provided, so paste the same value 10 times 
function! s:YRPaste(replace_last_paste_selection, nextvalue, direction, ...) 
    " Disabling the yankring removes the default maps.
    " But there are some maps the user can create on their own, and 
    " these would most likely call this function.  So place an extra
    " check and display a message.
    if g:yankring_enabled == 0
        call s:YRWarningMsg(
                    \ 'YR: The yankring is currently disabled, use YRToggle.'
                    \ )
        return
    endif
    
    let user_register  = s:YRRegister()
    let default_buffer = ((&clipboard == 'unnamed')?'*':'"')
    let v_count        = v:count

    " Default command mode to normal mode 'n'
    let cmd_mode = 'n'
    if a:0 > 0
        " Change to visual mode, if command executed via
        " a visual map
        let cmd_mode = ((a:1 == 'v') ? 'v' : 'n')
    endif

    " User has decided to bypass the yankring and specify a specific 
    " register
    if user_register != default_buffer
        if a:replace_last_paste_selection == 1
            echomsg 'YR: A register cannot be specified in replace mode'
            return
        else
            " Check for the expression register, in this special case
            " we must copy it's content into the default buffer and paste
            if user_register == '='
                let user_register = ''
                call setreg(default_buffer, histget('=', -1) )
            else
                let user_register = '"'.user_register
            endif
            exec "normal! ".
                        \ ((cmd_mode=='n') ? "" : "gv").
                        \ ((v_count > 0)?(v_count):'').
                        \ user_register.
                        \ a:direction
            " In this case, we have bypassed the yankring
            " If the user hits next or previous we want the
            " next item pasted to be the top of the yankring.
            let s:yr_last_paste_idx = 0
        endif
        let s:yr_paste_dir     = a:direction
        let s:yr_prev_vis_mode = ((cmd_mode=='n') ? 0 : 1)
        return
    endif

    " Try to second guess the user to make these mappings less intrusive.
    " If the user hits paste, compare the contents of the paste register
    " to the current entry in the yankring.  If they are different, lets
    " assume the user wants the contents of the paste register.
    " So if they pressed [yt ] (yank to space) and hit paste, the yankring
    " would not have the word in it, so assume they want the word pasted.
    if a:replace_last_paste_selection != 1 
        if s:yr_count > 0
            if getreg(default_buffer) != s:YRGetValElemNbr(0,'v')
                " The user has performed a yank / delete operation
                " outside of the yankring maps.  First, add this 
                " value to the yankring.
                call s:YRRecord(default_buffer)
                " Now, use the most recently yanked text, rather than the
                " value from the yankring.
                exec "normal! ".
                            \ ((cmd_mode=='n') ? "" : "gv").
                            \ ((v_count > 0)?(v_count):'').
                            \ a:direction
                let s:yr_paste_dir     = a:direction
                let s:yr_prev_vis_mode = ((cmd_mode=='n') ? 0 : 1)

                " In this case, we have bypassed the yankring
                " If the user hits next or previous we want the
                " next item pasted to be the top of the yankring.
                let s:yr_last_paste_idx = 0
                return
            endif
        else
            exec "normal! ".
                        \ ((cmd_mode=='n') ? "" : "gv").
                        \ ((v_count > 0)?(v_count):'').
                        \ a:direction
            let s:yr_paste_dir     = a:direction
            let s:yr_prev_vis_mode = ((cmd_mode=='n') ? 0 : 1)
            return
        endif
    endif

    if s:yr_count == 0
        echomsg 'YR: yankring is empty'
        " Nothing to paste
        return
    endif

    if a:replace_last_paste_selection == 1
        " Replacing the previous put
        let start = line("'[")
        let end = line("']")

        if start != line('.')
            echomsg 'YR: You must paste text first, before you can replace'
            return
        endif

        if start == 0 || end == 0
            return
        endif

        " If a count was provided (ie 5<C-P>), multiply the 
        " nextvalue accordingly and position the next paste index
        let which_elem = a:nextvalue * ((v_count > 0)?(v_count):1) * -1
        let s:yr_last_paste_idx = s:YRGetNextElem(
		    \ s:yr_last_paste_idx, which_elem
		    \ )

        let save_reg            = getreg(default_buffer)
        let save_reg_type       = getregtype(default_buffer)
        call setreg( default_buffer
                    \ , s:YRGetValElemNbr((s:yr_last_paste_idx-1),'v')
                    \ , s:YRGetValElemNbr((s:yr_last_paste_idx-1),'t')
                    \ )

        " First undo the previous paste
        exec "normal! u"
        " Check if the visual selection should be reselected
        " Next paste the correct item from the ring
        " This is done as separate statements since it appeared that if 
        " there was nothing to undo, the paste never happened.
        exec "normal! ".
                    \ ((s:yr_prev_vis_mode==0) ? "" : "gv").
                    \ s:yr_paste_dir
        call setreg(default_buffer, save_reg, save_reg_type)
        call s:YRSetPrevOP('', '', '')
    else
        " User hit p or P
        " Supports this for example -   5"ayy
        " And restores the current register
        let save_reg            = getreg(default_buffer)
        let save_reg_type       = getregtype(default_buffer)
        let s:yr_last_paste_idx = 1
        call setreg(default_buffer
                    \ , s:YRGetValElemNbr(0,'v')
                    \ , s:YRGetValElemNbr(0,'t')
                    \ )
        exec "normal! ".
                    \ ((cmd_mode=='n') ? "" : "gv").
                    \ (
                    \ ((v_count > 0)?(v_count):'').
                    \ a:direction
                    \ )
        call setreg(default_buffer, save_reg, save_reg_type)
        call s:YRSetPrevOP(
                    \ a:direction
                    \ , v_count
                    \ , default_buffer)
        let s:yr_paste_dir     = a:direction
        let s:yr_prev_vis_mode = ((cmd_mode=='n') ? 0 : 1)
    endif

endfunction
 

" Create the default maps
function! YRMapsCreate()

    " Iterate through a comma separated list of mappings and create
    " calls to the YRYankCount function
    if g:yankring_n_keys != ''
        let index = 0
        while index > -1
            " Retrieve the keystrokes for the mappings
            let sep_end = match(g:yankring_n_keys, g:yankring_separator, index)
            if sep_end > 0
                let cmd = strpart(g:yankring_n_keys, index, (sep_end - index))
            else
                let cmd = strpart(g:yankring_n_keys, index)
            endif
            " Creating the mapping and pass the key strokes into the
            " YRYankCount function so it knows how to replay the same
            " command
            if strlen(cmd) > 0
                exec 'nnoremap <silent>'.cmd." :<C-U>YRYankCount '".cmd."'<CR>"
            endif
            " Move onto the next entry in the comma separated list
            let index = index + strlen(cmd) + strlen(g:yankring_separator)
            if index >= strlen(g:yankring_n_keys)
                break
            endif
        endwhile
    endif
    if g:yankring_map_dot == 1
        exec "nnoremap <silent> .  :<C-U>YRYankCount '.'<CR>"
    endif
    if g:yankring_v_key != ''
        exec 'vnoremap <silent>'.g:yankring_v_key." :YRYankRange 'v'<CR>"
    endif
    if g:yankring_del_v_key != ''
        exec 'vnoremap <silent>'.g:yankring_del_v_key." :YRDeleteRange 'v'<CR>"
    endif
    if g:yankring_paste_n_bkey != ''
        exec 'nnoremap <silent>'.g:yankring_paste_n_bkey." :<C-U>YRPaste 'P'<CR>"
        if g:yankring_paste_using_g == 1
            exec 'nnoremap <silent> g'.g:yankring_paste_n_bkey." :<C-U>YRPaste 'gP'<CR>"
        endif
    endif
    if g:yankring_paste_n_akey != ''
        exec 'nnoremap <silent>'.g:yankring_paste_n_akey." :<C-U>YRPaste 'p'<CR>"
        if g:yankring_paste_using_g == 1
            exec 'nnoremap <silent> g'.g:yankring_paste_n_akey." :<C-U>YRPaste 'gp'<CR>"
        endif
    endif
    if g:yankring_paste_v_bkey != ''
        exec 'vnoremap <silent>'.g:yankring_paste_v_bkey." :<C-U>YRPaste 'P', 'v'<CR>"
    endif
    if g:yankring_paste_v_akey != ''
        exec 'vnoremap <silent>'.g:yankring_paste_v_akey." :<C-U>YRPaste 'p', 'v'<CR>"
    endif
    if g:yankring_replace_n_pkey != ''
        exec 'nnoremap <silent>'.g:yankring_replace_n_pkey." :<C-U>YRReplace '-1', 'P'<CR>"
    endif
    if g:yankring_replace_n_nkey != ''
        exec 'nnoremap <silent>'.g:yankring_replace_n_nkey." :<C-U>YRReplace '1', 'p'<CR>"
    endif

    let g:yankring_enabled = 1
endfunction
 

" Create the default maps
function! YRMapsDelete()

    " Iterate through a comma separated list of mappings and create
    " calls to the YRYankCount function
    if g:yankring_n_keys != ''
        let index = 0
        while index > -1
            " Retrieve the keystrokes for the mappings
            let sep_end = match(g:yankring_n_keys, g:yankring_separator, index)
            if sep_end > 0
                let cmd = strpart(g:yankring_n_keys, index, (sep_end - index))
            else
                let cmd = strpart(g:yankring_n_keys, index)
            endif
            " Creating the mapping and pass the key strokes into the
            " YRYankCount function so it knows how to replay the same
            " command
            if strlen(cmd) > 0
                exec 'nunmap '.cmd
            endif
            " Move onto the next entry in the comma separated list
            let index = index + strlen(cmd) + strlen(g:yankring_separator)
            if index >= strlen(g:yankring_n_keys)
                break
            endif
        endwhile
    endif
    if g:yankring_map_dot == 1
        exec "nunmap ."
    endif
    if g:yankring_v_key != ''
        exec 'vunmap '.g:yankring_v_key
    endif
    if g:yankring_del_v_key != ''
        exec 'vunmap '.g:yankring_del_v_key
    endif
    if g:yankring_paste_n_bkey != ''
        exec 'nunmap '.g:yankring_paste_n_bkey
        if g:yankring_paste_using_g == 1
            exec 'nunmap g'.g:yankring_paste_n_bkey
        endif
    endif
    if g:yankring_paste_n_akey != ''
        exec 'nunmap '.g:yankring_paste_n_akey
        if g:yankring_paste_using_g == 1
            exec 'nunmap g'.g:yankring_paste_n_akey
        endif
    endif
    if g:yankring_paste_v_bkey != ''
        exec 'vunmap '.g:yankring_paste_v_bkey
    endif
    if g:yankring_paste_v_akey != ''
        exec 'vunmap '.g:yankring_paste_v_akey
    endif
    if g:yankring_replace_n_pkey != ''
        exec 'nunmap '.g:yankring_replace_n_pkey
    endif
    if g:yankring_replace_n_nkey != ''
        exec 'nunmap '.g:yankring_replace_n_nkey
    endif

    let g:yankring_enabled = 0
endfunction

function! s:YRGetValElemNbr( position, type )

    let needed_elem = a:position

    if needed_elem > s:yr_count
        " The yankring is a ring, so if an element is
        " requested beyond the number of elements, we
        " must wrap around the ring.
        let needed_elem = needed_elem % s:yr_count
    endif

    if needed_elem < 0
        " The yankring is a ring, so if an element is
        " requested beyond the number of elements, we
        " must wrap around the ring.
        " let needed_elem = s:yr_count + needed_elem + 1
        let needed_elem = s:yr_count + needed_elem 
    endif

    " The MRU stores the *order* of the items in the
    " yankring, not the value.  These are stored within
    " script variables.
    let elem = get(s:yr_elements, needed_elem)

    if elem >= 0
        if a:type == 't'
            if exists(s:yr_scope.':YR_ELEM_TYPE_'.elem)
                return {s:yr_scope}:YR_ELEM_TYPE_{elem}
            endif
        else
            if exists(s:yr_scope.':YR_ELEM_'.elem)
                return {s:yr_scope}:YR_ELEM_{elem}
            endif
        endif
    else
        return -1
    endif

    return ""
endfunction

function! s:YRMRUInit( mru_list, max_size, initial_values )

    " Create the list if required
    if empty({a:mru_list}) && a:initial_values != ''
        let {a:mru_list} = split(a:initial_values, ',')
    endif

    if len({a:mru_list}) > a:max_size
        " Ensure list does not exceed maximum size
        call remove({a:mru_list}, a:max_size, -1)
    endif

    call s:YRMRUExport(a:mru_list)

    return 0
endfunction

function! s:YRMRUReset( mru_list )

    let {a:mru_list} = []

    call s:YRMRUExport(a:mru_list)

    return 1
endfunction

function! s:YRMRUSize( mru_list )
    return len({a:mru_list})
endfunction

function! s:YRMRUHas( mru_list, find_str )
    " This function will find a string and return the element #
    let find_idx = index({a:mru_list}, a:find_str)

    return find_idx
endfunction

function! s:YRMRUGet( mru_list, position )
    " This function will return the value of the item at a:position
    " Find the value of one element
    let value = get({a:mru_list}, a:position, -2)

    return value
endfunction

function! s:YRMRUAdd( mru_list, element, element_type )
    " Only add new items if they do not already exist in the MRU.
    " If the item is found, move it to the start of the MRU.
    let found      = -1
    let elem       = ''
    let elem_index = 0
    for elem_item in {a:mru_list}
        let elem = s:YRGetValElemNbr(elem_index, 'v')
        " If the item has been found, move it to the start of the list
        " unless of course it is already at the start
        if elem == a:element && elem_item > 0
            call remove({a:mru_list}, elem_index)
            call insert({a:mru_list}, elem_item)
            let found = elem_index
            break
        endif
        let elem_index += 1
    endfor

    if found == -1
        let {s:yr_scope}:YR_ELEM_{s:yr_next_idx}       = a:element
        let {s:yr_scope}:YR_ELEM_TYPE_{s:yr_next_idx}  = a:element_type
        let elem_index                                 = s:yr_next_idx
        let s:yr_next_idx                             += 1
        call insert({a:mru_list}, elem_index)
    endif

    " Allow (retain) only g:yankring_max_history in the MRU list.
    " Remove/discard the remaining entries. As we are adding a one entry to
    " the list, the list should have only g:yankring_max_history - 1 in it.
    let curr_cnt = s:YRMRUSize(a:mru_list)

    if curr_cnt > g:yankring_max_history
        " Since the yankring is full, set the s:yr_next_idx
        " to the last item in the MRU list
        " Return -1 if this fails
        let s:yr_next_idx = get({a:mru_list}, -1, -1)
        call remove({a:mru_list}, -1)

        if s:yr_next_idx == -1
            call s:YRErrorMsg(
                        \ 'YRMRUAdd: Last element not found: '.
                        \ {a:mru_list}.':'.
                        \ {a:mru_list}
                        \ )
        endif
    endif

    let s:yr_count = s:YRMRUSize(a:mru_list)

    call s:YRMRUExport(a:mru_list)

    return 1
endfunction

function! s:YRMRUDel( mru_list, elem_nbr )

    " This regex determines how many elements to keep
    " at the front of the yankring
    call remove({a:mru_list}, a:elem_nbr)

    let s:yr_count = s:YRMRUSize(a:mru_list)

    call s:YRMRUExport(a:mru_list)

    return 1
endfunction

function! s:YRMRUExport( mru_list )
    " Export the List into the variable.  If this is a global variable
    " a comma separated list is created as a global variable so that
    " it can be saved within the viminfo file.
    if s:yr_scope == 'g'
        let {s:yr_scope}:YR_ELEM_ORDER = join({a:mru_list}, ',')
    endif
endfunction

" YRWindowUpdate
" Checks if the yankring window is already open.
" If it is, it will refresh it.
function! s:YRWindowUpdate()
    let orig_win_bufnr = bufwinnr('%')

    " Switch to the yankring buffer
    " only if it is already visible
    if bufwinnr(s:yr_buffer_id) != -1
        call s:YRShow(0)
        " Switch back to the original buffer
        exec orig_win_bufnr . "wincmd w"
    endif
endfunction

" YRWindowStatus
" Displays a brief command list and option settings.
" It also will toggle the Help text.
function! s:YRWindowStatus(show_help)

    let orig_win_bufnr = bufwinnr('%')
    let yr_win_bufnr   = bufwinnr(s:yr_buffer_id)

    if yr_win_bufnr == -1
        " Do not update the window status since the
        " yankring is not currently displayed.
        return ""
    endif
    " Switch to the yankring buffer
    if orig_win_bufnr != yr_win_bufnr 
        " If the buffer is visible, switch to it
        exec yr_win_bufnr . "wincmd w"
    endif

    let msg = 'AutoClose='.g:yankring_window_auto_close.
                \ ';Cmds:<enter>,[g]p,[p]P,d,r,a,u,q,<space>;Help=?'.
                \ (s:yr_search==""?"":';SearchRegEx='.s:yr_search)

    " Toggle help by checking the first line of the buffer
    if a:show_help == 1 && getline(1) !~ 'selection'
        let msg = 
                    \ '" <enter>      : [p]aste selection'."\n".
                    \ '" double-click : [p]aste selection'."\n".
                    \ '" [g]p         : [g][p]aste selection'."\n".
                    \ '" [g]P         : [g][P]aste selection'."\n".
                    \ '" r            : [p]aste selection in reverse order'."\n".
                    \ '" u            : update display'."\n".
                    \ '" a            : toggle autoclose setting'."\n".
                    \ '" q            : Close the yankring window'."\n".
                    \ '" ?            : Remove help text'."\n".
                    \ '" <space>      : toggles the width of the window'."\n".
                    \ '" Visual mode is supported for above commands'."\n".
                    \ msg
    endif 

    let saveMod = &modifiable

    " Go to the top of the buffer and remove any previous status
    " Use the blackhole register so it does not affect the yankring
    setlocal modifiable
    exec 0
    silent! exec 'norm! "_d/^---'."\n"
    call histdel("search", -1)

    silent! 0put =msg

    let &modifiable = saveMod

    if orig_win_bufnr != s:yr_buffer_id 
        exec orig_win_bufnr . "wincmd w"
    endif
endfunction

" YRWindowOpen
" Display the Most Recently Used file list in a temporary window.
function! s:YRWindowOpen(results)

    " Setup the cpoptions properly for the maps to work
    let old_cpoptions = &cpoptions
    set cpoptions&vim
    setlocal cpoptions-=a,A

    " Save the current buffer number. The yankring will switch back to
    " this buffer when an action is taken.
    let s:yr_buffer_last       = bufnr('%')
    let s:yr_buffer_last_winnr = winnr()

    if bufwinnr(s:yr_buffer_id) == -1

        if g:yankring_window_use_horiz == 1
            if g:yankring_window_use_bottom == 1
                let location = 'botright'
            else
                let location = 'topleft'
            endif
            let win_size = g:yankring_window_height
        else
            " Open a horizontally split window. Increase the window size, if
            " needed, to accomodate the new window
            if g:yankring_window_width &&
                        \ &columns < (80 + g:yankring_window_width)
                " one extra column is needed to include the vertical split
                let &columns             = &columns + g:yankring_window_width + 1
                let s:yankring_winsize_chgd = 1
            else
                let s:yankring_winsize_chgd = 0
            endif

            if g:yankring_window_use_right == 1
                " Open the window at the rightmost place
                let location = 'botright vertical'
            else
                " Open the window at the leftmost place
                let location = 'topleft vertical'
            endif
            let win_size = g:yankring_window_width
        endif

        " Special consideration was involved with these sequence
        " of commands.  
        "     First, split the current buffer.
        "     Second, edit a new file.
        "     Third record the buffer number.
        " If a different sequence is followed when the yankring
        " buffer is closed, Vim's alternate buffer is the yanking
        " instead of the original buffer before the yankring 
        " was shown.
        silent exec location. ' ' . win_size . 'split '
        " Using :e and hide prevents the alternate buffer
        " from being changed.
        exec ":e " . escape(s:yr_buffer_name, ' ')
        " Save buffer id
        let s:yr_buffer_id = bufnr('%')
    else
        " If the buffer is visible, switch to it
        exec bufwinnr(s:yr_buffer_name) . "wincmd w"
    endif

    " Mark the buffer as scratch
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nowrap
    setlocal nonumber
    setlocal nobuflisted
    setlocal modifiable

    " Clear all existing maps for this buffer
    " We should do this for all maps, but I am not sure how to do
    " this for this buffer/window only without affecting all the
    " other buffers.
    mapclear <buffer>
    " Create a mapping to act upon the yankring
    nnoremap <buffer> <silent> <2-LeftMouse> :call <SID>YRWindowActionN('p','n')<CR>
    nnoremap <buffer> <silent> <CR>          :call <SID>YRWindowActionN('p','n')<CR>
    vnoremap <buffer> <silent> <CR>          :call <SID>YRWindowAction('p','v')<CR>
    nnoremap <buffer> <silent> p             :call <SID>YRWindowActionN('p','n')<CR>
    vnoremap <buffer> <silent> p             :call <SID>YRWindowAction('p','v')<CR>
    nnoremap <buffer> <silent> P             :call <SID>YRWindowActionN('P','n')<CR>
    vnoremap <buffer> <silent> P             :call <SID>YRWindowAction('P','v')<CR>
    nnoremap <buffer> <silent> gp            :call <SID>YRWindowActionN('gp','n')<CR>
    vnoremap <buffer> <silent> gp            :call <SID>YRWindowAction('gp','v')<CR>
    nnoremap <buffer> <silent> gP            :call <SID>YRWindowActionN('gP','n')<CR>
    vnoremap <buffer> <silent> gP            :call <SID>YRWindowAction('gP','v')<CR>
    nnoremap <buffer> <silent> d             :call <SID>YRWindowActionN('d','n')<CR>
    vnoremap <buffer> <silent> d             :call <SID>YRWindowAction('d','v')<CR>
    vnoremap <buffer> <silent> r             :call <SID>YRWindowAction('r','v')<CR>
    nnoremap <buffer> <silent> a             :call <SID>YRWindowAction('a','n')<CR>
    nnoremap <buffer> <silent> ?             :call <SID>YRWindowAction('?','n')<CR>
    nnoremap <buffer> <silent> u             :call <SID>YRShow(0)<CR>
    nnoremap <buffer> <silent> q             :call <SID>YRWindowAction('q','n')<CR>
    nnoremap <buffer> <silent> <space>     \|:silent exec 'vertical resize '.
                \ (
                \ g:yankring_window_use_horiz!=1 && winwidth('.') > g:yankring_window_width
                \ ?(g:yankring_window_width)
                \ :(winwidth('.') + g:yankring_window_increment)
                \ )<CR>

    " Erase it's contents to the blackhole
    %delete _

    " Display the status line / help 
    call s:YRWindowStatus(0)

    " Display the contents of the yankring
    silent! put =a:results

    " Move the cursor to the first line with an element
    exec 0
    call search('^\d','W') 

    setlocal nomodifiable
    "
    " Restore the previous cpoptions settings
    let &cpoptions = old_cpoptions

endfunction

function! s:YRWindowActionN(op, cmd_mode) 
    let v_count    = v:count
    " If no count was specified it will have a value of 0
    " so set it to at least 1
    let v_count = ((v_count > 0)?(v_count):1)

    if v_count > 1
        if !exists("b:yankring_show_range_error")
            let b:yankring_show_range_error = v_count
        else
            let b:yankring_show_range_error = b:yankring_show_range_error - 1
        endif

        if b:yankring_show_range_error == 1
            call s:YRWarningMsg("YR:Use visual mode if you need to specify a count")
            unlet b:yankring_show_range_error
        endif
        return
    endif
    
    " while v_count > 0
        call s:YRWindowAction(a:op, a:cmd_mode)
        let v_count = v_count - 1
    " endwhile

    if g:yankring_window_auto_close == 1 && v_count == 0
        exec 'bdelete '.bufnr(s:yr_buffer_name)
        return "" 
    endif

    return "" 
endfunction

function! s:YRWindowAction(op, cmd_mode) range
    let default_buffer = ((&clipboard=='unnamed')?'*':'"')
    let opcode     = a:op
    let saveA      = getreg('a')
    let saveA_t    = getregtype('a')
    let saveD      = getreg(default_buffer)
    let saveD_t    = getregtype(default_buffer)
    let lines      = ""
    let v_count    = v:count
    let cmd_mode   = a:cmd_mode
    let firstline  = a:firstline
    let lastline   = a:lastline

    if cmd_mode == 'n'
        let v_count = 1
        " if v_count > 1
        "     call s:YRWarningMsg('Use visual mode to apply a count')
        "     return
        " endif
        " If a count was provided (5p), we want to repeat the paste
        " 5 times, but this also alters the a:firstline and a:lastline
        " ranges, which while in normal mode we do not want
        let lastline = firstline
    endif
    " If no count was specified it will have a value of 0
    " so set it to at least 1
    let v_count = ((v_count > 0)?(v_count):1)

    if '[dr]' =~ opcode 
        " Reverse the order of the lines to act on
        let begin = lastline
        while begin >= firstline 
            let lines = lines."\n".getline(begin)
            let begin = begin - 1
        endwhile
    else
        " Process the selected items in order
        exec firstline.','.lastline.'yank a'
        let lines = "\n".@a
    endif
    call setreg('a', saveA, saveA_t)
    call setreg(default_buffer, saveD, saveD_t)

    if opcode ==# 'q'
        " Close the yankring window
        if s:yankring_winsize_chgd == 1
            " Adjust the Vim window width back to the width
            " it was before we showed the yankring window
            let &columns= &columns - (g:yankring_window_width)
        endif

        hide
        return
    elseif opcode ==# 'u'
        call s:YRShow(0)
        return
    elseif opcode ==# 'a'
	let l:curr_line = line(".")
        " Toggle the auto close setting
        let g:yankring_window_auto_close = 
                    \ (g:yankring_window_auto_close == 1?0:1)
        " Display the status line / help 
        call s:YRWindowStatus(0)
	call cursor(l:curr_line,0)
        return
    elseif opcode ==# '?'
        " Display the status line / help 
        call s:YRWindowStatus(1)
        return
    endif

    " Switch back to the original buffer
    exec s:yr_buffer_last_winnr . "wincmd w"
    
    " Intentional case insensitive comparision
    if opcode =~? 'p'
        let cmd   = 'YRGetElem '
        let parms = ", '".opcode."' "
    elseif opcode ==? 'r'
        let opcode = 'p'
        let cmd    = 'YRGetElem '
        let parms  = ", 'p' "
    elseif opcode ==# 'd'
        let cmd   = 'YRPop '
        let parms = ""
    endif

    " Only execute this code if we are operating on elements
    " within the yankring
    if '[auq?]' !~# opcode 
        while v_count > 0
            let iter  = 0
            let index = 0
            let index = match(lines, "\n".'\d\+', index)
            while index > -1
                " Retrieve the keystrokes for the mappings
                let index = match(lines, "\n".'\d\+', index)
                let elem  = matchstr(lines, "\n".'\zs\d\+', index)

                if elem > 0 && elem <= s:yr_count
                    if iter > 0 && opcode =~# 'p'
                        " Move to the end of the last pasted item
                        " only if pasting after (not above)
                        ']
                    endif
                    exec cmd . elem . parms
                    let iter += 1
                endif
                " Search for the next element beginning with a newline character
                " Add +2, 1 to go by the number, 1 for the newline character
                let index = index + strlen(elem) + 2 
                if index >= strlen(lines)
                    break
                endif
                let index = match(lines, "\n".'\d\+', index)
            endwhile
            let v_count = v_count - 1
        endwhile

        if opcode ==# 'd'
            call s:YRShow(0)
            return ""
        endif

        if g:yankring_window_auto_close == 1 && cmd_mode == 'v'
            exec 'bdelete '.bufnr(s:yr_buffer_name)
            return "" 
        endif

    endif

    return "" 

endfunction
      
function! s:YRWarningMsg(msg)
    echohl WarningMsg
    echomsg a:msg 
    echohl None
endfunction
      
function! s:YRErrorMsg(msg)
    echohl ErrorMsg
    echomsg a:msg 
    echohl None
endfunction
      
function! s:YRWinLeave()
    " Track which window we are last in.  We will use this information
    " to determine where we need to paste any contents, or which 
    " buffer to return to.
    
    if s:yr_buffer_id < 0
        " The yankring window has never been activated
        return
    endif

    if winbufnr(winnr()) == s:yr_buffer_id
        " Ignore leaving the yankring window
        return
    endif

    if bufwinnr(s:yr_buffer_id) != -1
        " YankRing window is visible, so save off the previous buffer ids
        let s:yr_buffer_last_winnr = winnr()
        let s:yr_buffer_last       = winbufnr(s:yr_buffer_last_winnr)
    " else
    "     let s:yr_buffer_last_winnr = -1
    "     let s:yr_buffer_last       = -1
    endif
endfunction

" Deleting autocommands first is a good idea especially if we want to reload
" the script without restarting vim.
" Call YRInit in the VimEnter event so that the global variables have been
" restored via the viminfo file.  Calling YRInit prior to this will 
" not restore the yankring order or items.
augroup YankRing
    autocmd!
    autocmd VimEnter * :call <SID>YRInit()
    autocmd WinLeave * :call <SID>YRWinLeave()
augroup END


" Public commands
command!                           YRClear       call s:YRClear()
command! -range -bang     -nargs=? YRDeleteRange <line1>,<line2>call s:YRYankRange(<bang>1, <args>)
command!                  -nargs=* YRGetElem     call s:YRGetElem(<args>)
command!        -bang     -nargs=? YRGetMultiple call s:YRGetMultiple(<bang>0, <args>)
command! -count -register -nargs=* YRPaste       call s:YRPaste(0,1,<args>)
command!                  -nargs=? YRPop         <line1>,<line2>call s:YRPop(<args>)
command!        -register -nargs=? YRPush        call s:YRPush(<args>)
command! -count -register -nargs=* YRReplace     call s:YRPaste(1,<args>)
command!                  -nargs=? YRSearch      call s:YRSearch(<q-args>)
" command!                  -nargs=1 YRSetTop      call s:YRSetTop(<args>)
command!                  -nargs=? YRShow        call s:YRShow(<args>)
command!                  -nargs=? YRToggle      call s:YRToggle(<args>)
command! -count -register -nargs=* YRYankCount   call s:YRYankCount(<args>)
command! -range -bang     -nargs=? YRYankRange   <line1>,<line2>call s:YRYankRange(<bang>0, <args>)

" Verify the viminfo setting has !, which is required to 
" persist global variables
if s:yr_scope == 'g'
    if &viminfo !~ '!'
        call s:YRWarningMsg('YR: The yankring can only persist if the viminfo setting has a "!" ')
    endif
endif

if g:yankring_enabled == 1
    " Create YankRing Maps
    call YRMapsCreate()
endif

if exists('*YRRunAfterMaps') 
    " This will allow you to override the default maps if necessary
    call YRRunAfterMaps()
endif

call s:YRInit()
      

" vim:fdm=marker:nowrap:ts=4:expandtab:
