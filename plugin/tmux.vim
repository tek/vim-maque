"{{{ options
let g:maque_tmux_main_split_cmd = 'tmux split-window -h -d'
let g:maque_tmux_aux_split_cmd = 'tmux split-window -v -d -p 20'
let g:maque_tmux_bg_split_cmd = 'tmux new-window -d'
let g:maque_tmux_filter_escape_sequences = 1
let g:maque_tmux_pane_escape_filter = "sed -u -e \"s/\r//g\" -e \"s/\e[[0-9;]*m//g\""
let g:maque_tmux_kill_signals = ['INT', 'TERM', 'KILL']
let g:maque_tmux_minimize_on_toggle = 1
let g:maque_tmux_error_pane = 'main'
let g:maque_tmux_default_panes = 1
let g:maque_tmux_minimal_shell = 'zsh -f'

if (argc() > 0 && argv(0) =~ '\.git') || exists('g:maque_remote')
  let g:maque_tmux_default_panes = 0
endif
"}}}

let g:maque_tmux_layouts = {}
let g:maque_tmux_panes = {}
let g:maque_tmux_current_pane = ''
let g:maque_tmux_exiting = 0

let g:maque_tmux_mappings = [
      \ ['focus'],
      \ ['kill'],
      \ ['close'],
      \ ['toggle-pane'],
      \ ['toggle-layout'],
      \ ['minimize-pane'],
      \ ['minimize-layout'],
      \ ['reset-capture'],
      \ ['cycle-panes'],
      \ ['buffer',
      \  'call maque#tmux#create_buffer_pane(<q-args>)' .
      \  '<Bar>call maque#make_auto()'],
      \ ['debuffer', 'call maque#tmux#delete_buffer_pane()', 0],
      \ ['add-pane', '', '+'],
      \ ]

for params in g:maque_tmux_mappings
  call call('maque#interface#tmux_command_mapping', params)
endfor

augroup maque_tmux "{{{
  autocmd!
  autocmd VimLeave * call maque#tmux#close_all()
  autocmd User MaqueTmuxPanesCreated call maque#tmux#finish_init()
augroup END "}}}
