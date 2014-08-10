let s:profiles = {
      \ 'maque_command': ['exclude_commands'],
      \ 'maque_stopped': ['stopped_commands', 'exclude_commands'],
      \ 'maque_pane': ['exclude_panes'],
      \ 'maque_open': ['open_panes', 'exclude_panes'],
      \ }

for name in keys(s:profiles)
  call unite#custom#profile(name, 'filters', s:profiles[name])
endfor

call maque#interface#unite_source('tmux_pane',
      \ [['tmux-pane-all', ''], ['tmux-pane', 'pane'],
      \ ['open-tmux-pane', 'open']]
      \ )

call maque#interface#unite_source('command',
      \ [['command-all', ''], ['command', 'command'],
      \ ['stopped-command', 'stopped']]
      \ )

let g:maque_unite_tmux_pane_mappings = 1

let g:maque_unite_tmux_pane_mapping_kill = 'K'
let g:maque_unite_tmux_pane_mapping_toggle = 'T'
let g:maque_unite_tmux_pane_mapping_close = 'C'
let g:maque_unite_tmux_pane_mapping_activate = 'A'
let g:maque_unite_tmux_pane_mapping_parse = 'P'
let g:maque_unite_tmux_pane_mapping_focus = 'F'

let g:maque_unite_tmux_pane_ignore = ['vim']

let g:maque_unite_command_mappings = 1

let g:maque_unite_command_mapping_make = 'M'
let g:maque_unite_command_mapping_set_main = 'S'
let g:maque_unite_command_mapping_toggle = 'T'

let g:maque_unite_command_ignore = ['main', 'status']
