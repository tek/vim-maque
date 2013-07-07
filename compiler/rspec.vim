if exists('current_compiler')
  finish
endif
let current_compiler = 'rspec'

set errorformat=
    \%f:%l:\ parse\ error,
    \%f:%l:\ warning:\ %m,
    \%f:%l:in\ %*[^:]:\ %m,
    \%[\ #]%#%f:%l:in\ %m,
    \%f:%l:\ %m,
    \%\\s%#from\ %f:%l:%m,
    \%\\s%#from\ %f:%l,
    \%-G%.%#

let s:cpo_save = &cpo
set cpo-=C

CompilerSet makeprg=rspec

let &cpo = s:cpo_save
unlet s:cpo_save
