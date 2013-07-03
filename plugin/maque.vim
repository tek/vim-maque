let g:maque_leave_conque = 1
let g:maque_handler = 'tmux'
let g:maque_conque_horizontal = 1
let g:maque_conque_term_nowrap = 0
let g:maque_makeprg_set = 0
let g:maque_default_command = 'make'
let g:maque_tmux_vertical = 1
let g:maque_jump_to_error = 'first'
let g:maque_handlers = ['tmux', 'dispatch', 'conque', 'native']

nnoremap <silent> <Plug>Maque :call maque#make()<cr>
nnoremap <silent> <Plug>AutoMaque :call maque#make_auto()<cr>
nnoremap <silent> <Plug>MaqueFile :call maque_common#set_file()<Bar>call maque#make()<cr>
nnoremap <silent> <Plug>MaqueLine :call maque_common#set_line()<Bar>call maque#make()<cr>
nnoremap <silent> <Plug>MaqueQuery :call maque#query()<Bar>call maque#make()<cr>
nnoremap <silent> <Plug>MaqueParse :call maque#parse()<cr>
nnoremap <silent> <Plug>MaqueCycle :call maque#cycle()<cr>
