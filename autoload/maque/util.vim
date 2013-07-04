function! maque#util#buffer_is_in_project(num) "{{{
  let path = expand('#'.a:num.':p')
  try
    let path = system('realpath '.path)
  catch
  endtry
  return path =~ getcwd()
endfunction "}}}
