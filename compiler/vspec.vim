if exists('current_compiler')
  finish
endif
let current_compiler = 'vspec'

let s:cpo_save = &cpo
set cpo-=C

CompilerSet makeprg=vspec

let &cpo = s:cpo_save
unlet s:cpo_save
