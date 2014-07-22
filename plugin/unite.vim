noremap <silent> <plug>(maque-unite-tmux-pane) :Unite -auto-resize maque_tmux_pane<cr>
noremap <silent> <plug>(maque-unite-command) :Unite -auto-resize maque_command<cr>

let g:maque_unite_tmux_pane_mappings = 1

let g:maque_unite_tmux_pane_mapping_kill = 'K'
let g:maque_unite_tmux_pane_mapping_toggle = 'T'
let g:maque_unite_tmux_pane_mapping_close = 'C'
let g:maque_unite_tmux_pane_mapping_activate = 'A'
let g:maque_unite_tmux_pane_mapping_parse = 'P'
let g:maque_unite_tmux_pane_mapping_focus = 'F'

let g:maque_unite_command_mappings = 1

let g:maque_unite_command_mapping_make = 'M'
let g:maque_unite_command_mapping_set_main = 'S'
let g:maque_unite_command_mapping_toggle = 'T'
