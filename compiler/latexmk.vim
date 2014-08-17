if exists('current_compiler')
  finish
endif
let current_compiler = 'latexmk'

CompilerSet makeprg=latexmk
