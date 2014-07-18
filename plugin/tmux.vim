"{{{ options
let g:maque_tmux_main_split_cmd = 'tmux split-window -h -d'
let g:maque_tmux_aux_split_cmd = 'tmux split-window -v -d -p 20'
let g:maque_tmux_bg_split_cmd = 'tmux new-window -d'
let g:maque_tmux_filter_escape_sequences = 1
let g:maque_tmux_pane_escape_filter = "sed -u -e \"s/\r//g\" -e \"s/\e[[0-9;]*m//g\""
let g:maque_tmux_kill_signals = ['INT', 'TERM', 'KILL']
let g:maque_tmux_minimize_on_toggle = 1
let g:maque_tmux_map_focus_vim = 1
let g:maque_tmux_focus_vim_key = 'f12'
let g:maque_tmux_error_pane = 'main'
let g:maque_tmux_default_panes = 1
let g:maque_tmux_minimal_shell = 'zsh -f'
"}}}

let g:maque_tmux_layouts = {}
let g:maque_tmux_panes = {}
let g:maque_tmux_current_pane = ''

augroup maque_tmux "{{{
  autocmd!
  autocmd VimLeave * call maque#tmux#close_all()
augroup END "}}}
