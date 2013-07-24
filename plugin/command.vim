let g:maque_commands = { }

let s:main_params = {
      \ 'type': 'eval',
      \ 'ptype': 'eval',
      \ 'pane': 'maque#current_pane()',
      \ }

call maque#add_command('main', 'maque#prg()', s:main_params)
