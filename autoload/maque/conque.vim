function! maque#conque#make(cmd) "{{{
  call maque#conque#delete_buffer()
  let remain = g:maque_leave_conque
  let split = g:maque_conque_horizontal ? 'botright vsplit' : 'botright split'
  let g:maque_conque_term = conque_term#open(a:cmd, [split], remain)
  let g:maque_conque_term_name = 'ConqueTerm_'.g:maque_conque_term.idx
  if g:maque_conque_term_nowrap
    exe 'py '.g:maque_conque_term_name.'.working_columns = 1000'
  endif
  let nr = bufnr(g:maque_conque_term.buffer_name)
  if exists('*populate#unlock_all') && !remain
    call populate#unlock_all()
    exe 'augroup conque_test'
    exe 'autocmd BufEnter <buffer='.nr.'> PopulateLock'
    exe 'autocmd BufLeave <buffer='.nr.'> silent! PopulateUnlock'
    exe 'augroup end'
  endif
  if remain
    stopinsert
  endif
endfunction "}}}

function! maque#conque#activate_window_by_name(name) "{{{
  let num = bufwinnr(a:name)
  if num >= 0
    exe num.'wincmd w'
  endif
endfunction "}}}

function! maque#conque#delete_buffer() "{{{
  if exists('g:maque_conque_term')
    silent! exe 'autocmd! '.term_name
    exe 'py '.g:maque_conque_term_name.'.close()'
    silent! exe 'py '.g:maque_conque_term_name.'.auto_read()'
    silent! exe 'bwipeout! '.g:maque_conque_term.buffer_name
    unlet g:maque_conque_term
    augroup conque_test
      autocmd!
    augroup end
    cclose
  endif
endfunction "}}}

function! maque#conque#write_errorfile(origin_name) "{{{
  stopinsert
  let in_conque = &ft == 'conque_term'
  if !in_conque
    call maque#conque#activate_window_by_name(g:maque_conque_term.buffer_name)
  endif
  silent exe 'w! '.&errorfile
  if in_conque && len(a:origin_name)
    call maque#conque#activate_window_by_name(a:origin_name)
  else
    wincmd p
  endif
endfunction "}}}

function! maque#conque#parse(origin_name) "{{{
  call maque#conque#write_errorfile(a:origin_name)
  cgetfile
  call maque#remove_errorfile()
  let nr = winnr()
  call maque#conque#activate_window_by_name(g:maque_conque_term.buffer_name)
  copen
  exe nr.'wincmd w'
	clast
  normal! zv
endfunction "}}}

function! maque#conque#start_service(cmd) "{{{
  let proc = conque_term#open(a:cmd, ['split'])
  wincmd c
  return proc
endfunction "}}}
