if g:maque_set_ft_options
  let current_path = expand('%')
  if current_path =~ '/androidTest/'
    call maque#apply_makeprg('adb-shell')
    let b:maque_filetype = 'sbt_android_test'
  elseif current_path =~ '/test/'
    let b:maque_filetype = 'scalatest'
    call maque#apply_makeprg('test-only')
  endif
endif
