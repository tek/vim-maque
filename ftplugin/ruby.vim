if g:maque_set_ft_options
  let current_path = expand('%')
  if current_path =~ '_spec.rb$'
    compiler rspec
    let b:maque_filetype = 'rspec'
    let b:maque_args_rspec_default = ''
  elseif current_path =~ 'Gemfile'
    setlocal makeprg=bundle
    let b:maque_filetype = 'gemfile'
  endif
endif
