if !exists('g:vim_bundles_path')
  let g:vim_bundles_path = expand('~/.vim/bundle')
endif

let g:maque_dir = fnamemodify(expand('<sfile>:h').'/..', ':p')
