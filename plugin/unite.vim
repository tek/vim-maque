"{{{ options
let g:maque_unite_tmux_pane_config_defaults = {
      \ 'mappings': 1,
      \ 'mapping_kill': 'K',
      \ 'mapping_toggle': 'T',
      \ 'mapping_close': 'C',
      \ 'mapping_activate': 'A',
      \ 'mapping_parse': 'P',
      \ 'mapping_focus': 'F',
      \ 'ignore': ['vim'],
      \ }

call maque#interface#config_options(g:maque_unite_tmux_pane_config_defaults,
      \ 'unite_tmux_pane')

let g:maque_unite_command_config_defaults = {
      \ 'mappings': 1,
      \ 'mapping_make': 'M',
      \ 'mapping_set_main': 'S',
      \ 'mapping_toggle': 'T',
      \ 'ignore': ['main', 'status'],
      \ }

call maque#interface#config_options(g:maque_unite_command_config_defaults,
      \ 'unite_command')
"}}}

"{{{ filter profiles
let s:profiles = {
      \ 'maque_command': ['exclude_commands'],
      \ 'maque_stopped': ['stopped_commands', 'exclude_commands'],
      \ 'maque_pane': ['exclude_panes'],
      \ 'maque_open': ['open_panes', 'exclude_panes'],
      \ }

for name in keys(s:profiles)
  call unite#custom#profile(name, 'filters', s:profiles[name])
endfor
"}}}

"{{{ mappings & commands
call maque#interface#unite_source('tmux_pane',
      \ [['tmux-pane-all', ''], ['tmux-pane', 'pane'],
      \ ['open-tmux-pane', 'open']]
      \ )

call maque#interface#unite_source('command',
      \ [['command-all', ''], ['command', 'command'],
      \ ['stopped-command', 'stopped']]
      \ )
"}}}
