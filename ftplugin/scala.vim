if g:maque_set_ft_options
  let current_path = expand('%')
  if current_path =~ '/androidTest/'
    call maque#util#scala#set_android_test()
  elseif current_path =~ '\v/test(-src)?/'
    call maque#util#scala#set_scalatest()
  endif
endif
