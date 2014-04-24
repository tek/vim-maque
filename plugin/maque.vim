"{{{ dependencies
if exists(':NeoBundleDepends')
  NeoBundleDepends 'Shougo/vimproc.vim'
endif
"}}}

"{{{ options
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
let g:maque_loaded = 1
let g:maque_async = 1
let g:maque_use_make_fallback = 0
"}}}

"{{{ commands
command! -nargs=* Maque                 call maque#make(<q-args>)
command! -nargs=* MaqueAux              call maque#make_aux(<q-args>)
command! AutoMaque                      call maque#make_auto()
command! MaqueFile                      call maque#ft#common#set_file()<Bar>call maque#make()
command! MaqueLine                      call maque#ft#common#set_line()<Bar>call maque#make()
command! MaqueQuery                     call maque#query()<Bar>call maque#make()
command! -nargs=? MaqueParse            call maque#parse(<f-args>)
command! MaqueCycle                     call maque#cycle()
command! -nargs=? MaqueToggleTmux       call maque#tmux#toggle(<f-args>)
command! -nargs=? MaqueTmuxKill         call maque#tmux#kill(<f-args>)
command! -nargs=* MaqueTmuxBuffer       call maque#tmux#create_buffer_pane(<q-args>)<Bar>call maque#make_auto()
command! MaqueTmuxDebuffer              call maque#tmux#delete_buffer_pane()
command! MaqueTmuxCycle                 call maque#tmux#cycle_panes()
command! -nargs=+ MaqueTmuxAddPane      call maque#tmux#add_pane(<f-args>)
command! MaqueTmuxClose                 call maque#tmux#close_pane()
command! MaqueTmuxMinimize              call maque#tmux#minimize()
command! -nargs=? MaqueTmuxResetCapture call maque#tmux#reset_capture(<q-args>)
command! -nargs=1 MaqueRunCommand       call maque#make_command(<q-args>)
command! -nargs=1 MaqueToggleCommand    call maque#toggle_command(<q-args>)
"}}}

"{{{ mappings
nnoremap <silent> <Plug>(maque)               :Maque<cr>
nnoremap <silent> <Plug>(auto-maque)          :AutoMaque<cr>
nnoremap <silent> <Plug>(maque-file)          :MaqueFile<cr>
nnoremap <silent> <Plug>(maque-line)          :MaqueLine<cr>
nnoremap <silent> <Plug>(maque-query)         :MaqueQuery<cr>
nnoremap <silent> <Plug>(maque-parse)         :MaqueParse<cr>
nnoremap <silent> <Plug>(maque-cycle)         :MaqueCycle<cr>
nnoremap <silent> <Plug>(maque-toggle-tmux)   :MaqueToggleTmux<cr>
nnoremap <silent> <Plug>(maque-tmux-kill)     :MaqueTmuxKill<cr>
nnoremap <silent> <Plug>(maque-tmux-buffer)   :MaqueTmuxBuffer<cr>
nnoremap <silent> <Plug>(maque-tmux-debuffer) :MaqueTmuxDebuffer<cr>
nnoremap <silent> <Plug>(maque-tmux-cycle)    :MaqueTmuxCycle<cr>
nnoremap <silent> <Plug>(maque-tmux-close)    :MaqueTmuxClose<cr>
"}}}

augroup maque "{{{
  autocmd!
  autocmd VimLeavePre * call maque#save_maqueprg()
  autocmd VimEnter * call maque#load_maqueprg()
augroup END "}}}
