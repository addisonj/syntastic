"============================================================================
"File:        cpp.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Gregor Uhlenheuer <kongo2002 at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

" in order to also check header files add this to your .vimrc:
" (this usually creates a .gch file in your source directory)
"
"   let g:syntastic_cpp_check_header = 1

if exists('loaded_cpp_syntax_checker')
    finish
endif
let loaded_cpp_syntax_checker = 1

if !executable('g++')
    finish
endif

function! SyntaxCheckers_cpp_GetLocList()
    if exists('g:syntastic_cpp_user_config')
        let useropts = SyntaxCheckers_cpp_ParseConfig()
    else
        let useropts = ''
    endif

    let makeprg = 'g++ -fsyntax-only '. useropts .shellescape(expand('%'))
    let errorformat =  '%-G%f:%s:,%f:%l:%c: %m,%f:%l: %m'

    if expand('%') =~? '\%(.h\|.hpp\|.hh\)$'
        if exists('g:syntastic_cpp_check_header')
            let makeprg = 'g++ -c '. useropts .shellescape(expand('%'))
        else
            return []
        endif
    endif

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction

" Borrowed from Rip-Rip/clang_complete
function! SyntaxCheckers_cpp_ParseConfig()
    let l:options = ''

    let l:local_conf = findfile('.syntastic_cpp_config', getcwd() . ',.;')
    if l:local_conf == '' || !filereadable(l:local_conf)
        return l:options
    endif

    let l:opts = readfile(l:local_conf)
    for l:opt in l:opts
        if matchstr(l:opt, '\C-I\s*/') != ''
            let l:opt = substitute(l:opt, '\C-I\s*\(/\%(\w\|\\\s\)*\)',
                \ '-I' . '\1', 'g')
        else
	    " convert relative to absolute path so we can be in subdir
            let l:opt = substitute(l:opt, '\C-I\s*\(\%(\w\|\\\s\)*\)',
                \ '-I' . l:local_conf[:-22] . '\1', 'g')
	endif
        let l:options .= ' ' . l:opt
        endfor
    return l:options . ' '
endfunction
