if exists('current_compiler')
  finish
endif
let current_compiler = 'spec'

setlocal errorformat=
	\%A\ \ File\ \"%f\"\\\,\ line\ %l\\\,%m,
	\%C\ \ \ \ %.%#,
	\%+Z%.%#Error\:\ %.%#,
	\%A\ \ File\ \"%f\"\\\,\ line\ %l,
	\%+C\ \ %.%#,
	\%-C%p^,
	\%Z%m,
	\%-G%.%#

let s:cpo_save = &cpo
set cpo-=C

CompilerSet makeprg=spec

let &cpo = s:cpo_save
unlet s:cpo_save

