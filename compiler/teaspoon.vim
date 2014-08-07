if exists('current_compiler')
  finish
endif
let current_compiler = 'teaspoon'

let s:cpo_save = &cpo
set cpo-=C

CompilerSet makeprg=teaspoon

let &cpo = s:cpo_save
unlet s:cpo_save
