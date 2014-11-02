if exists('current_compiler')
  finish
endif
let current_compiler = 'ant_javac'

set errorformat=
      \%A\ %#[javac]\ %f:%l:\ %m,
      \%-Z\ %#[javac]\ %p^,
      \%A\ %#[iajc]\ %f:%l:0::0\ %m,
      \%-Z\ %#[iajc]\ %p^,
      \%-G%.%#

let s:cpo_save = &cpo
set cpo-=C

CompilerSet makeprg=ant

let &cpo = s:cpo_save
unlet s:cpo_save
