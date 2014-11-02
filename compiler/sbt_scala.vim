if exists('current_compiler')
  finish
endif
let current_compiler = 'sbt_scala'

set errorformat=
      \%A\ %#[error]\ %f:%l:\ %m,
      \%-Z\ %#[error]\ %p^,
      \%A\ %#[warn]\ %f:%l:\ %m,
      \%-Z\ %#[warn]\ %p^,
      \%-G%.%#

let s:cpo_save = &cpo
set cpo-=C

CompilerSet makeprg=sbt

let &cpo = s:cpo_save
unlet s:cpo_save
