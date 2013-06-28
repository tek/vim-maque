function! maque#activate_window_by_name(name) "{{{
  let num = bufwinnr(a:name)
  if num >= 0
    exe num.'wincmd w'
  endif
endfunction "}}}

function! maque#delete_buffer() "{{{
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

function! maque#make_conque(cmd) "{{{
  call maque#delete_buffer()
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

function! maque#make_tmux(cmd) "{{{
  if ! g:ScreenShellActive
    if g:maque_tmux_vertical
      ScreenShellVertical
    else
      ScreenShell
    end
    call g:ScreenShellSend('cd '.g:pwd)
  end
  call g:ScreenShellSend(a:cmd)
endfunction "}}}

function! maque#make_dispatch(cmd) "{{{
  Make
endfunction "}}}

function! maque#make_native(cmd) "{{{
  make!
endfunction "}}}

function! maque#make(...) "{{{
	let cmd = a:0 > 0 ? a:1 : &makeprg
  return call(g:maque_maker, [cmd])
endfunction "}}}

function! maque#make_auto() "{{{
  let do_set = 1
  let default_setter = 'maque_'.&ft.'#set_makeprg'
  exe 'runtime autoload/maque_'.&ft.'.vim'
  if exists('b:maque_makeprg_setter') && exists('*'.b:maque_makeprg_setter)
    let setter_name = b:maque_makeprg_setter
  elseif exists('g:maque_makeprg_setter') && exists('*'.g:maque_makeprg_setter)
    let setter_name = g:maque_makeprg_setter
  elseif exists('*'.default_setter)
    let setter_name = default_setter
  else
		echohl WarningMsg | echo 'maque: no makeprg setter found!' | echohl None
    let do_set = 0
  endif
  let do_make = g:maque_makeprg_set
  if do_set
    let Setter = function(setter_name)
    let do_make = Setter() || do_make
  endif
  if do_make
    return maque#make()
  endif
endfunction "}}}

function! maque#write_errorfile(origin_name) "{{{
  stopinsert
  let in_conque = &ft == 'conque_term'
  if !in_conque
    call maque#activate_window_by_name(g:maque_conque_term.buffer_name)
  endif
  silent exe 'w! '.&errorfile
  if in_conque && len(a:origin_name)
    call maque#activate_window_by_name(a:origin_name)
  else
    wincmd p
  endif
endfunction "}}}

function! maque#remove_errorfile() "{{{
	exe 'silent !'.'rm -f '.&ef
  redraw!
endfunction "}}}

function! maque#parse_output(origin_name) "{{{
  call maque#write_errorfile(a:origin_name)
  cgetfile
  call maque#remove_errorfile()
  let nr = winnr()
  call maque#activate_window_by_name(g:maque_conque_term.buffer_name)
  copen
  exe nr.'wincmd w'
	clast
  normal! zv
endfunction "}}}

function! maque#start_service(cmd) "{{{
  let proc = conque_term#open(a:cmd, ['split'])
  wincmd c
  return proc
endfunction "}}}

function! maque#command() "{{{
  if exists('b:maque_command')
    return b:maque_command
  elseif exists('g:maque_command')
    return g:maque_command
  elseif exists('b:maque_default_command')
    return b:maque_default_command
  else
    return g:maque_default_command
  fi
endfunction "}}}

function! maque#query() "{{{
  let fname = input('File name: ', '', 'file')
  let &makeprg = maque#command().' '.fname
endfunction "}}}
