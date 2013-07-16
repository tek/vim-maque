function! maque#make(...) "{{{
  if a:0 && len(a:1)
    let g:maqueprg = a:1
  endif
  let Maker = function('maque#'.g:maque_handler.'#make')
  return Maker(maque#prg())
endfunction "}}}

function! maque#make_auto() "{{{
  let do_set = 1
  let default_setter = 'maque#ft#'.maque#filetype().'#set_makeprg'
  exe 'runtime! autoload/maque/ft/'.maque#filetype().'.vim'
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
    call maque#dispatch#focus()
    return maque#make()
  endif
endfunction "}}}

function! maque#remove_errorfile() "{{{
	exe 'silent !'.'rm -f '.&ef
  redraw!
endfunction "}}}

function! maque#args() "{{{
  for src in ['', 'default_']
    for scope in ['b', 'g']
      let var = scope.':maque_args_'.src.&makeprg
      if exists(var)
        return {var}
      endif
    endfor
  endfor
  return ''
endfunction "}}}

function! maque#query() "{{{
  let fname = input('File name: ', '', 'file')
  call maque#set_params(fname)
endfunction "}}}

function! maque#filetype() "{{{
  return exists('b:maque_filetype') ? b:maque_filetype : &filetype
endfunction "}}}

function! maque#parse() "{{{
  let Parser = function('maque#'.g:maque_handler.'#parse')
  return Parser()
endfunction "}}}

function! maque#cycle() "{{{
  let h_index = index(g:maque_handlers, g:maque_handler)
  let h_index = (h_index + 1) % len(g:maque_handlers)
  let g:maque_handler = g:maque_handlers[h_index]
  echo 'selected maque handler "'.g:maque_handler.'".'
endfunction "}}}

function! maque#cwd_error_index() "{{{
  let last = g:maque_jump_to_error == 'last'
  let error_list = getqflist()
  if last
    call reverse(error_list)
  endif
  for error in error_list
    if maque#util#buffer_is_in_project(error.bufnr)
      return index(getqflist(), error) + 1
    endif
  endfor
  return last ? len(error_list) : 1
endfunction "}}}

function! maque#jump_to_error() "{{{
  if len(g:maque_jump_to_error)
    if g:maque_seek_cwd_error
      let index = maque#cwd_error_index()
      execute 'cc! '.index
    else
      execute 'c'.g:maque_jump_to_error
    endif
    normal! zv
  endif
endfunction "}}}

function! maque#prg() "{{{
  if !exists('g:maqueprg')
    call maque#set_params('')
  endif
  return g:maqueprg
endfunction "}}}

function! maque#set_params(params) "{{{
  let g:maqueprg = &makeprg.' '.maque#args().' '.a:params
endfunction "}}}
