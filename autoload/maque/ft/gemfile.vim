function! maque#ft#gemfile#set_makeprg() "{{{
  let current_path = expand('%')
  let params = 'install'
  if fnamemodify(current_path, ':t') != 'Gemfile'
    let params .= ' --gemfile=' . current_path
  endif
  return maque#set_params(params)
endfunction "}}}
