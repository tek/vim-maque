"{{{ options
let g:maque_tmux_config_defaults = {
      \ 'main_split_cmd': 'split-window -h -d',
      \ 'bg_split_cmd': 'new-window -d',
      \ 'filter_escape_sequences': 1,
      \ 'pane_escape_filter': "sed -u -e \"s/\r//g\" -e \"s/\e[[0-9;]*m//g\"",
      \ 'kill_signals': ['INT', 'TERM', 'KILL'],
      \ 'minimize_on_toggle': 1,
      \ 'error_pane': 'main',
      \ 'default_panes': 1,
      \ 'minimal_shell': 'zsh -f',
      \ }

call maque#interface#config_options(g:maque_tmux_config_defaults, 'tmux')

if (argc() > 0 && argv(0) =~ '\.git') || exists('g:maque_remote')
      \ || exists('$NO_MAQUE')
  let g:maque_tmux_default_panes = 0
endif
"}}}

let g:maque_tmux_layouts = {}
let g:maque_tmux_panes = {}
let g:maque_tmux_current_pane = ''
let g:maque_tmux_exiting = 0

"{{{ mappings & commands
" syntax: [name, dispatch, args]
" args corresponds to :command's -nargs parameter
" dispatch is the callback that should be executed
" if dispatch is not given, maque#tmux#<name>(...) is used
" command and <plug> mappings are generated from name
let g:maque_tmux_mappings = [
      \ ['focus'],
      \ ['kill'],
      \ ['kill_wait'],
      \ ['close'],
      \ ['toggle-pane'],
      \ ['toggle-layout'],
      \ ['minimize-pane'],
      \ ['minimize-layout'],
      \ ['reset-capture'],
      \ ['cycle-panes'],
      \ ['cycle-panes'],
      \ ['clear-log'],
      \ ['send', 'call maque#tmux#_send_cmd(<q-args>)', '+'],
      \ ['buffer',
      \  'call maque#tmux#create_buffer_pane(<q-args>)' .
      \  '<Bar>call maque#make_auto()'],
      \ ['debuffer', 'call maque#tmux#delete_buffer_pane()', 0],
      \ ['add-pane', '', '+'],
      \ ]

for params in g:maque_tmux_mappings
  call call('maque#interface#tmux_command_mapping', params)
endfor
"}}}

augroup maque_tmux "{{{
  autocmd!
  autocmd User MaqueTmuxPanesCreated call maque#tmux#finish_init()
augroup END "}}}
