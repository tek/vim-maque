function! maque#tmux#setup#create_default_panes() abort "{{{
  echom 'create_default'
  let vim = maque#tmux#add_pane('vim', {
        \ '_splitter': '',
        \ 'capture': 0,
        \ }
        \ )
  let main = maque#tmux#add_pane('main', {
        \ 'eval_splitter': 1,
        \ '_splitter': 'g:maque_tmux_main_split_cmd',
        \ 'capture': 1,
        \ 'autoclose': 0,
        \ }
        \ )
  let aux = maque#tmux#add_pane('aux', {
        \ 'eval_splitter': 1,
        \ '_splitter': 'g:maque_tmux_aux_split_cmd', 
        \ 'capture': 0,
        \ 'autoclose': 1,
        \ 'vertical': 0,
        \ }
        \ )
  call maque#tmux#add_pane('bg', {
        \ 'eval_splitter': 1,
        \ '_splitter': 'g:maque_tmux_bg_split_cmd', 
        \ 'capture': 0,
        \ 'autoclose': 1,
        \ }
        \ )
  let status = maque#tmux#add_pane('status', {
        \ '_splitter': 'tmux split-window -v -d -p 30', 
        \ 'capture': 0,
        \ 'autoclose': 0,
        \ 'vertical': 0,
        \ 'size': 30,
        \ }
        \ )
  let g:maque_tmux_current_pane = 'main'
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
  call vim_layout.add(vim)
  call vim_layout.add(aux)
  call make_layout.add(main)
  call make_layout.add(status)

  let vim.id = maque#tmux#vim_id()
endfunction "}}}
