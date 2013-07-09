if g:maque_set_ft_options
  compiler nose
  let b:maque_filetype = 'nose'
  let b:maque_args_default_nosetests = '--nocapture'
endif
