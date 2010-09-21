" lodgeit.vim: Vim plugin for paste.pocoo.org
" Maintainer:   Armin Ronacher <armin.ronacher@active-4.com>
" Version:      0.2

" Usage:
"   :Lodgeit    create a paste from the current buffer of selection
"   :e <url>    download a paste. If you then use :Lodgeit you can
"               reply to that paste.
"
" If you want to paste on ctrl + p just add this to your vimrc:
" 	map ^P :Lodgeit<CR>
" (where ^P is entered using ctrl + v, ctrl + p in vim)

function! s:LodgeitInit()
python << EOF

import vim
import re
from xmlrpclib import ServerProxy
srv = ServerProxy('http://paste.pocoo.org/xmlrpc/', allow_none=True)

new_paste = srv.pastes.newPaste
get_paste = srv.pastes.getPaste

language_mapping = {
    'python':           'python',
    'php':              'html+php',
    'smarty':           'smarty',
    'tex':              'tex',
    'rst':              'rst',
    'cs':               'csharp',
    'haskell':          'haskell',
    'xml':              'xml',
    'html':             'html',
    'xhtml':            'html',
    'htmldjango':       'html+django',
    'django':           'html+django',
    'htmljinja':        'html+django',
    'jinja':            'html+django',
    'lua':              'lua',
    'scheme':           'scheme',
    'mako':             'html+mako',
    'c':                'c',
    'cpp':              'cpp',
    'javascript':       'js',
    'jsp':              'jsp',
    'ruby':             'ruby',
    'bash':             'bash',
    'bat':              'bat',
    'd':                'd',
    'genshi':           'html+genshi'
}

language_reverse_mapping = {}
for key, value in language_mapping.iteritems():
    language_reverse_mapping[value] = key

def paste_id_from_url(url):
    regex = re.compile(r'^http://paste.pocoo.org/show/([^/]+)/?$')
    m = regex.match(url)
    if m is not None:
        return m.group(1)

def make_utf8(code):
    enc = vim.eval('&fenc') or vim.eval('&enc')
    return code.decode(enc, 'ignore').encode('utf-8')

EOF
endfunction


function! s:Lodgeit(line1,line2,count,...)
call s:LodgeitInit()
python << endpython

# download paste
if vim.eval('a:0') == '1':
    paste = paste_id = None
    arg = vim.eval('a:1')

    if arg.startswith('#'):
        paste_id = arg[1:].split()[0]
    if paste_id is None:
        paste_id = paste_id_from_url(vim.eval('a:1'))
    if paste_id is not None:
        paste = get_paste(paste_id)

    if paste:
        vim.command('tabnew')
        vim.command('file Lodgeit\ Paste\ \#%s' % paste_id)
        vim.current.buffer[:] = paste['code'].splitlines()
        vim.command('setlocal ft=' + language_reverse_mapping.
                    get(paste['language'], 'text'))
        vim.command('setlocal nomodified')
        vim.command('let b:lodgeit_paste_id="%s"' % paste_id)
    else:
        print 'Paste not Found'

# new paste or reply
else:
    rng_start = int(vim.eval('a:line1')) - 1
    rng_end = int(vim.eval('a:line2'))
    if int(vim.eval('a:count')):
        code = '\n'.join(vim.current.buffer[rng_start:rng_end])
    else:
        code = '\n'.join(vim.current.buffer)
    code = make_utf8(code)

    parent = None
    update_buffer_info = False
    if vim.eval('exists("b:lodgeit_paste_id")') == '1':
        parent = int(vim.eval('b:lodgeit_paste_id'))
        update_buffer_info = True

    lng_code = language_mapping.get(vim.eval('&ft'), 'text')
    paste_id = new_paste(lng_code, code, parent)
    url = 'http://paste.pocoo.org/show/%s' % paste_id

    print 'Pasted #%s to %s' % (paste_id, url)
    vim.command(':call setreg(\'+\', %r)' % url)

    if update_buffer_info:
        vim.command('file Lodgeit\ Paste\ \#%s' % paste_id)
        vim.command('setlocal nomodified')
        vim.command('let b:lodgeit_paste_id="%s"' % paste_id)

endpython
endfunction


command! -range=0 -nargs=* Lodgeit :call s:Lodgeit(<line1>,<line2>,<count>,<f-args>)
