let s:cpo_save = &cpo
set cpo-=C

CompilerSet makeprg=zsh

let &cpo = s:cpo_save
unlet s:cpo_save
