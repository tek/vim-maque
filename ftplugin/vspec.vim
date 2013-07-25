if g:maque_set_ft_options
  compiler vspec
  let b:maque_filetype = 'vspec'
  let b:vspec_path_default = g:vim_bundles_path.'/vim-vspec'
  let vspec_path = maque#util#variable('vspec_path')
  let b:maque_args_vspec_default = '. '.vspec_path
endif
