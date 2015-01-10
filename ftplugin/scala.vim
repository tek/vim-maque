if g:maque_set_ft_options
  let current_path = expand('%')
  if current_path =~ '/androidTest/'
    let b:maque_filetype = 'sbt_android_test'
    let &l:makeprg = 'adb-shell'
  elseif current_path =~ '/test/'
    let b:maque_filetype = 'scalatest'
    let &l:makeprg = 'test-only'
  endif
endif
