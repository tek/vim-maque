"{{{ options
let g:maque_tmux_main_split_cmd = 'tmux split-window -h -d'
let g:maque_tmux_aux_split_cmd = 'tmux split-window -v -d -p 20'
let g:maque_tmux_bg_split_cmd = 'tmux new-window -d'
let g:maque_tmux_filter_escape_sequences = 1
let g:maque_tmux_pane_escape_filter = "sed -u -e \"s/\r//g\" -e \"s/\e[[0-9;]*m//g\""
let g:maque_tmux_kill_signals = ['INT', 'TERM', 'KILL']
let g:maque_tmux_minimize_on_toggle = 1
let g:maque_tmux_error_pane = 'main'
let g:maque_tmux_default_panes = 1
let g:maque_tmux_minimal_shell = 'zsh -f'

if (argc() > 0 && argv(0) =~ '\.git') || exists('g:maque_remote')
  let g:maque_tmux_default_panes = 0
endif
"}}}

let g:maque_tmux_layouts = {}
let g:maque_tmux_panes = {}
let g:maque_tmux_current_pane = ''
let g:maque_tmux_exiting = 0

"{{{ commands
command! -nargs=? MaqueTmuxToggleLayout   call maque#tmux#toggle_layout(<f-args>)
command! -nargs=? MaqueTmuxTogglePane     call maque#tmux#toggle(<f-args>)
command! -nargs=? MaqueTmuxKill           call maque#tmux#kill(<f-args>)
command! -nargs=* MaqueTmuxBuffer         call maque#tmux#create_buffer_pane(<q-args>)<Bar>call maque#make_auto()
command! MaqueTmuxDebuffer                call maque#tmux#delete_buffer_pane()
command! MaqueTmuxCycle                   call maque#tmux#cycle_panes()
command! -nargs=+ MaqueTmuxAddPane        call maque#tmux#add_pane(<f-args>)
command! MaqueTmuxClose                   call maque#tmux#close_pane()
command! -nargs=? MaqueTmuxMinimize       call maque#tmux#minimize(<q-args>)
command! -nargs=? MaqueTmuxMinimizeLayout call maque#tmux#minimize_layout(<q-args>)
command! -nargs=? MaqueTmuxResetCapture   call maque#tmux#reset_capture(<q-args>)
"}}}

"{{{ mappings
nnoremap <silent> <Plug>(maque-tmux-kill)        :MaqueTmuxKill<cr>
nnoremap <silent> <Plug>(maque-tmux-buffer)      :MaqueTmuxBuffer<cr>
nnoremap <silent> <Plug>(maque-tmux-debuffer)    :MaqueTmuxDebuffer<cr>
nnoremap <silent> <Plug>(maque-tmux-cycle)       :MaqueTmuxCycle<cr>
nnoremap <silent> <Plug>(maque-tmux-close)       :MaqueTmuxClose<cr>
nnoremap <silent> <Plug>(maque-tmux-toggle-make) :MaqueTmuxToggleLayout make<cr>
"}}}

augroup maque_tmux "{{{
  autocmd!
  autocmd VimLeave * call maque#tmux#close_all()
  autocmd User MaqueTmuxPanesCreated call maque#tmux#finish_init()
augroup END "}}}
