let g:maque_leave_conque = 1
let g:maque_maker = 'maque#make_conque'
let g:maque_conque_horizontal = 1
let g:maque_conque_term_nowrap = 0
let g:maque_makeprg_set = 0

nnoremap <silent> <Plug>Maque :call maque#make()<cr>
nnoremap <silent> <Plug>AutoMaque :call maque#make_auto()<cr>
