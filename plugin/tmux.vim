"{{{ options
let g:maque_tmux_main_split_cmd = 'tmux split-window -h -d'
let g:maque_tmux_aux_split_cmd = 'tmux split-window -v -d -p 20'
let g:maque_tmux_filter_escape_sequences = 1
let g:maque_tmux_pane_escape_filter = "sed -u -e \"s/\r//g\" -e \"s/\e[[0-9;]*m//g\""
let g:maque_tmux_kill_signals = ['INT', 'TERM', 'KILL']
"}}}

let g:maque_tmux_panes = {}
call maque#tmux#add_pane('main', { 'eval_splitter': 1,
      \ '_splitter': 'g:maque_tmux_main_split_cmd',
      \ 'capture': 1,
      \ 'autoclose': 0,
      \ }
      \ )
call maque#tmux#add_pane('aux', { 'eval_splitter': 1,
      \ '_splitter': 'g:maque_tmux_aux_split_cmd', 
      \ 'capture': 0,
      \ 'autoclose': 1,
      \ }
      \ )
let g:maque_tmux_current_pane = 'main'
