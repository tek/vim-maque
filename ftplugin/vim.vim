if g:maque_set_ft_options
  if expand('%:p') =~ '.*/t/.*.vim'
    compiler vspec
    let b:maque_args_default_rake = 'test'
  endif
endif
