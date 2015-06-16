if g:maque_add_default_commands && !exists('g:maque_remote')
  let g:maque_main_vim = maque#command#new_main_vim()
  call maque#add_command('auto', 'maque#auto_prg()', {
        \ 'cmd_type': 'eval',
        \ 'pane_type': 'eval',
        \ 'pane_name': 'maque#current_pane()',
        \ 'remember': 1,
        \ }
        \ )
  call maque#add_command('main', 'g:maque_mainprg', {
        \ 'cmd_type': 'eval',
        \ 'pane_type': 'eval',
        \ 'pane_name': 'maque#current_pane()',
        \ }
        \ )
  let g:maque_status =
        \ maque#command#new_vim('status', {'pane_name': 'status'})
  let commands = maque#commands()
  let commands['status'] = g:maque_status
  silent doautocmd User MaqueCommandsCreated
endif

function! s:preautocmd() abort "{{{
  let g:maque_auto = maque#command('auto')
  doautocmd User MaqueInitialized
endfunction "}}}

autocmd User MaqueInitializedPre call <sid>preautocmd()
