let g:maque_commands = { }
let g:maque_add_default_commands = 1
let g:maque_last_command = 'auto'

function! s:preautocmd() abort "{{{
  " commands aren't existent up to now
  let g:maque_auto = maque#command('auto')
  doautocmd User MaqueInitialized
endfunction "}}}

autocmd User MaqueInitializedPre call <sid>preautocmd()
