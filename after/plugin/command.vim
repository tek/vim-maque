function! s:preautocmd() abort "{{{
  " commands aren't existent up to now
  let g:maque_auto = maque#command('auto')
  doautocmd User MaqueInitialized
endfunction "}}}

autocmd User MaqueInitializedPre call <sid>preautocmd()
