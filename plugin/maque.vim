"{{{ dependencies
if exists(':NeoBundleDepends')
  NeoBundleDepends 'Shougo/vimproc.vim'
endif
"}}}

"{{{ options
let g:maque_config_defaults = {
      \ 'autostart': 1,
      \ 'autostart_commands': 1,
      \ 'startup_prevention_checker': 'maque#startup_prevention_checker',
      \ 'handler': 'tmux',
      \ 'makeprg_set': 0,
      \ 'jump_to_error': 'first',
      \ 'handlers': ['tmux', 'dispatch', 'native'],
      \ 'seek_cwd_error': 1,
      \ 'dispatch_command': 'Dispatch',
      \ 'set_ft_options': 0,
      \ 'loaded': 1,
      \ 'async': 1,
      \ 'use_make_fallback': 0,
      \ 'errors_in_status': 0,
      \ 'qf_path_ignore': [],
      \ 'android_test_runner_default':
        \ 'android.test.InstrumentationTestRunner',
      \ }

call maque#interface#config_options(g:maque_config_defaults)

let g:maqueprg = ''
let g:maque_mainprg = ''

"}}}

let g:_maque_scheduled_tasks = []

"{{{ mappings & commands
let g:maque_mappings = [
      \ ['start', '', 0],
      \ ['quit', '', 0],
      \ ['reset', '', 0],
      \ ['no-autostart', '', 0],
      \ ['cycle', '', 0],
      \ ['parse', '', '?'],
      \ ['run-command', '', 1],
      \ ['queue-command', '', 1],
      \ ['toggle-command', '', 1],
      \ ['add-service', '', '+'],
      \ ['add-captured-service', '', '+'],
      \ ['add-shell', '', '+'],
      \ ['add-command', 'call maque#create_command_cmd(<q-args>)', '+'],
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
  autocmd VimLeavePre * call maque#shutdown()
  autocmd VimEnter * call maque#startup()
augroup END "}}}
