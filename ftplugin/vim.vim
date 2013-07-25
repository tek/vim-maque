if g:maque_set_ft_options
  if expand('%:p') =~ '.*/t/.*.vim'
    runtime! ftplugin/vspec.vim
  endif
endif
