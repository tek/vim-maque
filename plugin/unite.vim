command! MaqueUniteTmuxPane Unite -auto-resize maque_tmux_pane
      \ -profile-name=maque_pane
command! MaqueUniteTmuxPaneAll Unite -auto-resize maque_tmux_pane
command! MaqueUniteOpenTmuxPane Unite -profile-name=maque_open -auto-resize
      \ maque_tmux_pane
command! MaqueUniteCommand Unite -auto-resize maque_command
      \ -profile-name=maque_command
command! MaqueUniteCommandAll Unite -auto-resize maque_command
command! MaqueUniteStoppedCommand Unite -auto-resize 
      \ -profile-name=maque_stopped maque_command

noremap <silent> <plug>(maque-unite-tmux-pane) :MaqueUniteTmuxPane<cr>
noremap <silent> <plug>(maque-unite-open-tmux-pane)
      \ :MaqueUniteOpenTmuxPane<cr>
noremap <silent> <plug>(maque-unite-open-tmux-pane-all)
      \ :MaqueUniteOpenTmuxPaneAll<cr>
noremap <silent> <plug>(maque-unite-command) :MaqueUniteCommand<cr>
noremap <silent> <plug>(maque-unite-stopped-command)
      \ :MaqueUniteStoppedCommand<cr>
noremap <silent> <plug>(maque-unite-stopped-command-all)
      \ :MaqueUniteStoppedCommandAll<cr>

call unite#custom#profile(
      \ 'maque_command', 'filters', ['exclude_commands'])
call unite#custom#profile(
      \ 'maque_pane', 'filters', ['exclude_panes'])
call unite#custom#profile(
      \ 'maque_stopped', 'filters', ['stopped_commands', 'exclude_commands'])
call unite#custom#profile(
      \ 'maque_open', 'filters', ['open_panes', 'exclude_panes'])

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
