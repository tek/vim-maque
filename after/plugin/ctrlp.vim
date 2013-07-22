if exists('g:loaded_ctrlp')
  command CtrlPMaqueTmux call ctrlp#init(ctrlp#maque#tmux#id())
  command CtrlPMaque     call ctrlp#init(ctrlp#maque#command#id())

  nnoremap <silent> <Plug>(ctrlp-maque)      :CtrlPMaque<cr>
  nnoremap <silent> <Plug>(ctrlp-maque-tmux) :CtrlPMaqueTmux<cr>
endif
