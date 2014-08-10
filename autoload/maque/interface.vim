"
" This file was automatically generated by riml 0.4.0
" Modify with care!
"
function! maque#interface#command_mapping(mapping, cmd_line, ...)
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let args = remove(__splat_var_cpy, 0)
  else
    let args = 0
  endif
  let mapping = len(a:mapping) ? 'maque-' . a:mapping : 'maque'
  let cmd_name = maque#util#command_name(mapping)
  execute 'command! -nargs=' . args . ' ' . cmd_name . ' ' . a:cmd_line
  if args ==# 0 || args ==# '*'
    execute 'noremap <silent> <plug>(' . mapping . ') :' . cmd_name . '<cr>'
  endif
endfunction

function! maque#interface#unite_command_mapping(mapping, cmd_line)
  let mapping = 'unite-' . a:mapping
  let cmd_line = 'Unite -auto-resize ' . a:cmd_line
  return maque#interface#command_mapping(mapping, cmd_line)
endfunction

function! maque#interface#unite_source(name, variants)
  for data in a:variants
    let [mapping, profile] = data
    let profile_param = (len(profile) ? '-profile-name=maque_' . profile : '')
    let source_name = 'maque_' . a:name
    let cmd_line = profile_param . ' ' . source_name
    call maque#interface#unite_command_mapping(mapping, cmd_line)
  endfor
endfunction

function! maque#interface#tmux_command_mapping(mapping, ...)
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let cmd_line = remove(__splat_var_cpy, 0)
  else
    let cmd_line = ''
  endif
  if !empty(__splat_var_cpy)
    let args = remove(__splat_var_cpy, 0)
  else
    let args = '*'
  endif
  let prefixed_mapping = 'tmux-' . a:mapping
  if !len(cmd_line)
    let cmd_line = 'call maque#tmux#' . substitute(a:mapping, '-', '_', 'g') . '(<q-args>)'
  endif
  return maque#interface#command_mapping(prefixed_mapping, cmd_line, args)
endfunction

function! maque#interface#maque_command_mapping(mapping, ...)
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let cmd_line = remove(__splat_var_cpy, 0)
  else
    let cmd_line = ''
  endif
  if !empty(__splat_var_cpy)
    let args = remove(__splat_var_cpy, 0)
  else
    let args = '0'
  endif
  if !len(cmd_line)
    let cmd_line = 'call maque#' . substitute(a:mapping, '-', '_', 'g') . '(<q-args>)'
  endif
  return maque#interface#command_mapping(a:mapping, cmd_line, args)
endfunction

function! maque#interface#maque_make_command_mapping(mapping, ...)
  let __splat_var_cpy = copy(a:000)
  if !empty(__splat_var_cpy)
    let args = remove(__splat_var_cpy, 0)
  else
    let args = '0'
  endif
  let cmd_line = 'call maque#make_' . substitute(a:mapping, '-', '_', 'g') . '(<q-args>)'
  return maque#interface#maque_command_mapping(a:mapping, cmd_line, args)
endfunction
