"{{{ dependencies
if exists(':NeoBundleDepends')
  NeoBundleDepends 'Shougo/vimproc.vim'
endif
"}}}

"{{{ options
let g:maque_leave_conque = 1
let g:maque_handler = 'tmux'
let g:maque_conque_horizontal = 1
let g:maque_conque_term_nowrap = 0
let g:maque_makeprg_set = 0
let g:maque_jump_to_error = 'first'
let g:maque_handlers = ['tmux', 'dispatch', 'conque', 'native']
let g:maque_seek_cwd_error = 1
let g:maque_dispatch_command = 'Dispatch'
let g:maque_set_ft_options = 0
let g:maque_loaded = 1
let g:maque_async = 1
let g:maque_use_make_fallback = 0
let g:_maque_scheduled_tasks = []
let g:maque_errors_in_status = 0
"}}}

let g:maque_mappings = [
      \ ['cycle'],
      \ ['parse', '', '?'],
      \ ['run-command', '', 1],
      \ ['toggle-command', '', 1],
      \ ['add-service', '', '+'],
      \ ['add-command', 'call maque#add_command_cmd(<q-args>)', '+'],
      \ ['query', 'call maque#query()<Bar>call maque#make()'],
      \ ]

for params in g:maque_mappings
  call call('maque#interface#maque_command_mapping', params)
endfor

let g:maque_make_mappings = [['', '*'], ['auto'], ['file'], ['line'], ['all']]

for params in g:maque_make_mappings
  call call('maque#interface#maque_make_command_mapping', params)
endfor

augroup maque "{{{
  autocmd!
  autocmd VimLeavePre * call maque#save_maqueprg()
  autocmd VimEnter * call maque#load_maqueprg()
augroup END "}}}
