" Vim plugin for blink(1).
" Version: 1.0
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:blink1#command')
  let g:blink1#command = 'blink1-tool'
endif
if !exists('g:blink1#color_table')
  let g:blink1#color_table = {
  \   'red': 0xFF0000,
  \   'green': 0x00FF00,
  \   'blue': 0x0000FF,
  \   'white': 0xFFFFFF,
  \   'black': 0x000000,
  \   'on': 0xFFFFFF,
  \   'off': 0x000000,
  \ }
endif


let s:Blink1 = {}

function! s:Blink1.on()
  call self.rgb(0xFF, 0xFF, 0xFF)
endfunction
function! s:Blink1.off()
  call self.rgb(0, 0, 0)
endfunction
function! s:Blink1.red()
  call self.rgb(0xFF, 0, 0)
endfunction
function! s:Blink1.green()
  call self.rgb(0, 0xFF, 0)
endfunction
function! s:Blink1.blue()
  call self.rgb(0, 0, 0xFF)
endfunction

function! s:Blink1.color(color)
  let rgb = get(g:blink1#color_table, a:color, a:color)
  if type(rgb) == type(0)
    let b = rgb % 0x100
    let rgb = rgb / 0x100
    let g = rgb % 0x100
    let rgb = rgb / 0x100
    let r = rgb % 0x100
  else
    let [r, g, b] = map(split(rgb, '[ ,]\+') + [0, 0, 0], 'v:val + 0')[: 2]
  endif
  return self.rgb(r, g, b)
endfunction
function! s:Blink1.rgb(r, g, b)
  return self.exec('--rgb ' . join([a:r, a:g, a:b], ','))
endfunction

function! s:Blink1.id()
  return get(self, '_id', -1)
endfunction

function! s:Blink1.set_fading(millis)
  let self._fading = a:millis
endfunction
function! s:Blink1.set_delay(millis)
  let self._delay = a:millis
endfunction
function! s:Blink1.set_gamma(on)
  let self._gamma = a:on
endfunction

function! s:Blink1.exec(args)
  let opt = []
  if has_key(self, '_vid')
    let opt += ['--vid=' . self._vid]
  elseif has_key(self, '_pid')
    let opt += ['--pid=' . self._pid]
  elseif has_key(self, '_id')
    if self._id < 0
      return  " dummy object
    endif
    let opt += ['--id', self._id]
  endif
  if has_key(self, '_fading')
    let opt += ['--millis=' . self._fading]
  endif
  if has_key(self, '_delay')
    let opt += ['--delay=' . self._delay]
  endif
  if !has_key(self, '_gamma') || !self._gamma
    let opt += ['--nogamma']
  endif
  let res = s:exec_blink1(join(opt + [a:args], ' '))
  let no_error = get(self, '_no_error', 0)
  " FIXME: Better approach for an error.
  if !no_error && res =~# 'no blink(1) devices found'
    throw 'blink1: no blink(1) devices found'
  endif
  if res =~# 'cannot open blink(1), bad serial number'
    let id = get(self, '_id', '')
    throw 'blink1: Can not open blink(1) device: --id=' . id
  endif
  return res
endfunction


function! blink1#new(id)
  let blink1 = copy(s:Blink1)
  let blink1._id = a:id
  return blink1
endfunction

function! blink1#all(...)
  let blink1 = blink1#new('all')
  let blink1._no_error = 1
  if a:0
    call extend(blink1, a:1)
  endif
  return blink1
endfunction

function! blink1#list()
  let res = split(s:exec_blink1('--list'), "\n")
  let devices = []
  for dev in res[1 :]
    let id = matchstr(dev, 'id:\zs\d\+') - 0
    let devices += [blink1#new(id)]
  endfor
  return devices
endfunction

function! blink1#first()
  let list = blink1#list()
  if empty(list)
    return blink1#new(-1)
  endif
  return list[0]
endfunction

let s:all_blink1 = blink1#all({'_fading': 0})

function! blink1#on()
  return s:all_blink1.on()
endfunction
function! blink1#off()
  return s:all_blink1.off()
endfunction
function! blink1#red()
  return s:all_blink1.red()
endfunction
function! blink1#green()
  return s:all_blink1.green()
endfunction
function! blink1#blue()
  return s:all_blink1.blue()
endfunction
function! blink1#color(color)
  return s:all_blink1.color(a:color)
endfunction
function! blink1#rgb(r, g, b)
  return s:all_blink1.rgb(a:r, a:g, a:b)
endfunction


function! s:exec_blink1(args)
  " TODO vimproc_bg
  return system(shellescape(g:blink1#command) . ' ' . a:args)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
