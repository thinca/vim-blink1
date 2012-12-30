" Vim plugin for blink(1).
" Version: 1.0
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

if exists('g:loaded_blink1')
  finish
endif
let g:loaded_blink1 = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=? Blink1 call blink1#color(<q-args>)

let &cpo = s:save_cpo
unlet s:save_cpo
