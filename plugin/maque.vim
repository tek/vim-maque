let g:maque_leave_conque = 1
let g:maque_handler = 'tmux'
let g:maque_conque_horizontal = 1
let g:maque_conque_term_nowrap = 0
let g:maque_makeprg_set = 0
let g:maque_jump_to_error = 'first'
let g:maque_handlers = ['tmux', 'dispatch', 'conque', 'native']
let g:maque_seek_cwd_error = 1
let g:maque_dispatch_command = 'Dispatch'
let g:maque_set_ft_options = 0
let g:maque_tmux_split_cmd = 'tmux split-window -h -d'
let g:maque_tmux_filter_escape_sequences = 1

command -nargs=* MaqueTmuxBuffer call maque#tmux#create_buffer_pane(<q-args>)<Bar>call maque#make_auto()
command MaqueTmuxDebuffer call maque#tmux#delete_buffer_pane()
command MaqueTmuxCycle call maque#tmux#cycle_panes()
command -nargs=+ MaqueTmuxAddPane call maque#tmux#add_pane(<f-args>)
command -nargs=* Maque call maque#make(<q-args>)
command AutoMaque call maque#make_auto()
command MaqueFile call maque#ft#common#set_file()<Bar>call maque#make()
command MaqueLine call maque#ft#common#set_line()<Bar>call maque#make()
command MaqueQuery call maque#query()<Bar>call maque#make()
command MaqueParse call maque#parse()
command MaqueCycle call maque#cycle()
command MaqueToggleTmux call maque#tmux#toggle_pane()
command MaqueTmuxKill call maque#tmux#kill()

nnoremap <silent> <Plug>Maque :Maque<cr>
nnoremap <silent> <Plug>AutoMaque :AutoMaque<cr>
nnoremap <silent> <Plug>MaqueFile :MaqueFile<cr>
nnoremap <silent> <Plug>MaqueLine :MaqueLine<cr>
nnoremap <silent> <Plug>MaqueQuery :MaqueQuery<cr>
nnoremap <silent> <Plug>MaqueParse :MaqueParse<cr>
nnoremap <silent> <Plug>MaqueCycle :MaqueCycle<cr>
nnoremap <silent> <Plug>MaqueToggleTmux :MaqueToggleTmux<cr>
