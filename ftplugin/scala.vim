if g:maque_set_ft_options
  let current_path = expand('%')
  if current_path =~ '/test/'
    let b:maque_filetype = 'scalatest'
  endif
endif
