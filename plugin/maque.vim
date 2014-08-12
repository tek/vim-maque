"{{{ dependencies
if exists(':NeoBundleDepends')
  NeoBundleDepends 'Shougo/vimproc.vim'
endif
"}}}

"{{{ options
let g:maque_config_defaults = {
      \ 'leave_conque': 1,
      \ 'handler': 'tmux',
      \ 'conque_horizontal': 1,
      \ 'conque_term_nowrap': 0,
      \ 'makeprg_set': 0,
      \ 'jump_to_error': 'first',
      \ 'handlers': ['tmux', 'dispatch', 'conque', 'native'],
      \ 'seek_cwd_error': 1,
      \ 'dispatch_command': 'Dispatch',
      \ 'set_ft_options': 0,
      \ 'loaded': 1,
      \ 'async': 1,
      \ 'use_make_fallback': 0,
      \ 'errors_in_status': 0,
      \ }

call maque#interface#config_options(g:maque_config_defaults)

"}}}

let g:_maque_scheduled_tasks = []

"{{{ mappings & commands
let g:maque_mappings = [
      \ ['cycle'],
      \ ['parse', '', '?'],
      \ ['run-command', '', 1],
      \ ['toggle-command', '', 1],
      \ ['add-service', '', '+'],
      \ ['add-captured-service', '', '+'],
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
"}}}

augroup maque "{{{
  autocmd!
  autocmd VimLeavePre * call maque#save_maqueprg()
  autocmd VimEnter * call maque#load_maqueprg()
augroup END "}}}
