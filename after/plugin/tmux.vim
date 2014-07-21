if g:maque_tmux_default_panes && !exists('g:maque_tmux_panes_created')
  let main_layout = maque#tmux#add_layout('main', {
        \ 'direction': 'horizontal',
        \ }
        \ )
  let vim_layout = maque#tmux#add_layout('vim', {
        \ 'direction': 'vertical',
        \ }
        \ )
  let make_layout = maque#tmux#add_layout('make', {
        \ 'direction': 'vertical',
        \ }
        \ )
  call main_layout.add(vim_layout)
  call main_layout.add(make_layout)
  let g:maque_tmux_layout_done = 1
  let vim = maque#tmux#add_vim_pane({
        \ '_splitter': '',
        \ 'capture': 0,
        \ }
        \ )
  call vim_layout.add(vim)
  let main = maque#tmux#add_pane_in_layout('main', 'make', {
        \ 'eval_splitter': 1,
        \ '_splitter': 'g:maque_tmux_main_split_cmd',
        \ 'capture': 1,
        \ 'autoclose': 0,
        \ }
        \ )
  let aux = maque#tmux#add_pane_in_layout('aux', 'vim', {
        \ 'eval_splitter': 1,
        \ '_splitter': 'g:maque_tmux_aux_split_cmd', 
        \ 'capture': 0,
        \ 'autoclose': 1,
        \ 'size': 15,
        \ 'minimal_shell': 1,
        \ }
        \ )
  call maque#tmux#add_pane('bg', {
        \ 'eval_splitter': 1,
        \ '_splitter': 'g:maque_tmux_bg_split_cmd', 
        \ 'capture': 0,
        \ 'autoclose': 1,
        \ 'minimal_shell': 1,
        \ }
        \ )
  let status = maque#tmux#add_pane_in_layout('status', 'make', {
        \ '_splitter': 'tmux split-window -v -d', 
        \ 'capture': 0,
        \ 'autoclose': 0,
        \ 'size': 15,
        \ 'minimal_shell': 1,
        \ }
        \ )
  let g:maque_tmux_current_pane = 'main'
  let g:maque_tmux_panes_created = 1
  call maque#util#run_scheduled_tasks()
  silent doautocmd User MaqueTmuxPanesCreated
endif
