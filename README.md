## Description

**maque** executes alternative methods to vim's :make command and assists in
assembling command lines.

A persistent tmux pane,
[Conque](https://github.com/rson/vim-conque 'github repo'),
[dispatch](https://github.com/tpope/vim-dispatch 'github repo') and
using vim's native `:make`
are currently supported methods.

## Usage

Essential mappings:  
`<Plug>(maque)` executes `g:maqueprg`  
`<Plug>(auto-maque)` calls a `g:maqueprg` setter function and executes it.  
`<Plug>(maque-parse)` populates the quickfix list using `'errorformat'`

## Customization

To add your own `make` replacement, assign a function name to
`g:maque_handler`.

To replace the default `g:maqueprg` assembly methods, assign yours to
`b:maque_makeprg_setter` or `g:maque_makeprg_setter`, or define the function
`maque#ft#{&filetype}#set_makeprg`. The function's return value is indicative
of whether make should be executed subsequently.  If none of these exist, the
plugin's default setter is used.

## Details

The main purpose of **maque** is to to assemble test invocation commands for
various filetypes and manage different test command dispatching methods. The
first execution of `AutoMaque` should be done with the cursor on the desired
unittest. After storing information about the currently selected environment,
custom mappings can launch different commands in conque or tmux (See the puppet
functions for an example).

The default assembly methods uses `'makeprg'` as executable. If a global or
buffer-local variable `maque_args_{&makeprg}` is set, it is appended.

After having executed a test, `<Plug>(maque-parse)` executes `:cgetfile`, which
populates the quickfix list identically to how :make does.

## tmux

The tmux method is designed to maintain a persistently open pane for
dispatching. Before and after each test execution, output redirection to a temp
file is (de)activated.
A mapping `<Plug>(maque-toggle-tmux)` is provided to manually kill or open the tmux
pane.

A new pane is created as a horizontal split by default, but you can specify an
arbitrary system command via `g:maque_tmux_split_cmd`. You can even launch a
new session in a fresh terminal by setting the variable to `'TMUX= urxvt -e
tmux &!'` (note that tmux will not nest, indicated by the `$TMUX` environment
variable). As long as as the pane is on localhost, it will be found.

There are two commands available to create additional panes:

`:MaqueTmuxAddPane name ['tmux split command']` creates a named pane which will
receive all following makes and toggle commands. It will become visible after
executing `<Plug>(maque)` or `<Plug>(maque-toggle-tmux)`.
To activate a different pane, run `:MaqueTmuxCycle` or assign its name to
`g:maque#tmux#current_pane`.

`:MaqueTmuxBuffer` and `:MaqueTmuxDebuffer` create and destroy a pane that is
associated with the current buffer and will receive all makes executed from it.

## Example

When editing an rspec file, the default `maque_args` are set to `--drb`. When
invoking the `<Plug>(auto-maque)` mapping, the default makeprg setter appends
`spec/current_file_spec.rb:23`, given that the cursor is on line 23. The whole
command line then becomes `rspec --drb spec/current_file_spec.rb:23`, which
will run only the example (group) under the cursor.

## License

Copyright (c) Torsten Schmits. Distributed under the same terms as Vim itself.
See `:help license`.
