function! maque#ft#chef_recipe#set_makeprg() "{{{
  if exists('g:maque_chef_node_name') && exists('g:maque_chef_cookbook')
    let recipe = g:maque_chef_cookbook . '::' . expand('%:t:r')
      let g:maqueprg = 'berks upload --force ' . g:maque_chef_cookbook .
            \ ' && knife ssh -x root "name:' . g:maque_chef_node_name .
            \ '" "chef-client -o recipe\[' . recipe . '\]"'
    return 1
  endif
endfunction "}}}
