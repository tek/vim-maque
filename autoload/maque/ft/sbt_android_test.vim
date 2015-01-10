function! maque#ft#sbt_android_test#set_makeprg() "{{{
  return maque#ft#sbt_android_test#set_line()
endfunction "}}}

function! maque#ft#sbt_android_test#set_file() "{{{
  return maque#util#scala#set_file('maque#ft#sbt_android_test#set_class')
endfunction "}}}

function! maque#ft#sbt_android_test#set_line() "{{{
  return maque#util#scala#set_file('maque#ft#sbt_android_test#set_line_impl')
endfunction "}}}

function! maque#ft#sbt_android_test#set_line_impl(package, class) abort "{{{
  let fun = maque#util#scala#current_function()
  if len(fun) == 0
    call maque#util#warn('No function definition above cursor')
  else
    let target = a:package . '.' . a:class . '#' . fun
    call maque#ft#sbt_android_test#set_params(a:package, target)
  endif
endfunction "}}}

function! maque#ft#sbt_android_test#set_class(package, class) abort "{{{
  let target = a:package . '.' . a:class
  call maque#ft#sbt_android_test#set_params(a:package, target)
endfunction "}}}

function! maque#ft#sbt_android_test#set_params(package, target) abort "{{{
  let runner = maque#util#variable('maque_android_test_runner')
  let test_spec = 'class ' . a:target
  let runner_spec = a:package . '/' . runner
  let params = ['-w', '-e', test_spec, runner_spec]
  call maque#set_params('am instrument ' . join(params, ' '))
endfunction "}}}
