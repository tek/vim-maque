if g:maque_set_ft_options
  if expand('%') =~ '_spec.rb$'
    compiler rspec
    let b:maque_filetype = 'rspec'
    let b:maque_args_rspec_default = ''
  endif
endif
