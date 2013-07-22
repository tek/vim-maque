let s:default_params = {
      \ 'type': 'eval',
      \ 'ptype': 'eval',
      \ 'pane': 'maque#current_pane()',
      \ }

let g:maque_command_main = maque#command#new('maque#prg()', s:default_params)
let g:maque_commands = {
      \ 'main': g:maque_command_main,
      \ }
