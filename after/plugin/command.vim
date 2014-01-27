if g:maque_add_default_commands
  let g:maque_main_vim = maque#command#vim#new('main_vim', '', {
        \ 'pane': 'vim',
        \ 'server_name': v:servername,
        \ }
        \ )
  call maque#add_command('main', 'maque#prg()', {
      \ 'type': 'eval',
      \ 'ptype': 'eval',
      \ 'pane': 'maque#current_pane()',
      \ }
      \ )
  let g:maque_status = maque#command#vim#new('status', '', {'pane': 'status'})
  let commands = maque#commands()
  let commands['status'] = g:maque_status
endif
