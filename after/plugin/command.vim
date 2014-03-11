if g:maque_add_default_commands && !exists('g:maque_remote')
  let g:maque_main_vim = maque#command#new_vim('main_vim', '', {
        \ 'pane_name': 'vim',
        \ 'server_name': v:servername,
        \ }
        \ )
  call maque#add_command('main', 'maque#prg()', {
        \ 'cmd_type': 'eval',
        \ 'pane_type': 'eval',
        \ 'pane_name': 'maque#current_pane()',
        \ }
        \ )
  let g:maque_status = maque#command#new_vim('status', '', {'pane_name': 'status'})
  let commands = maque#commands()
  let commands['status'] = g:maque_status
  silent doautocmd User MaqueCommandsCreated
endif
