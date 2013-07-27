## Description

**maque** assists in assembling context-dependent command lines, executing them
in a shell and capturing error output.

Maque's most significant component is its tmux integration. With default
settings, there are two standard panes used by the command handler:

- The **main** pane, a persistant horizontal split, is used to execute commands
  via `:Maque` and the command assembly mechanism.
- The **aux** pane, which is a volatile vertical split used for arbitrary
  commands.

Assembling commands is done through configurable setter functions. The defaults
provided mainly use the current file or line to configure the test program
executable, which is read from `'makeprg'`.

## Usage

The basic commands for using the default panes are demonstrated in this
presentation:

![basic_demo][1]

The **main** pane command, triggered by invoking `:Maque`, will execute
whatever the variable `g:maqueprg` contains. This variable is the target of
maque's command assembly functions, which can be used via `:AutoMaque` to set a
command line and execute it in the main pane.

After execution, `:MaqueParse` runs `:cgetfile` , populating the quickfix list
identically to how `:make` does.

Predefined mappings to these commands exist:

- `<Plug>(maque)` executes `g:maqueprg`  
- `<Plug>(auto-maque)` calls a `g:maqueprg` setter function and executes it.  
- `<Plug>(maque-parse)` populates the quickfix list using `'errorformat'`

## Customization

To employ different command execution methods or add your own, assign its name
to `g:maque_handler`. This will use the path prefix `maque#{g:maque_handler}#`
for all functions.

Maque provides support for serveral third-party execution methods aside from
its built-in tmux target:

- [conque](https://github.com/rson/vim-conque 'github repo')
- [dispatch](https://github.com/tpope/vim-dispatch 'github repo')
- vim's native `:make`

To replace the default `g:maqueprg` assembly methods, assign yours to
`b:maque_makeprg_setter` or `g:maque_makeprg_setter`, or define the function
`maque#ft#{&filetype}#set_makeprg`. The function's return value is indicative
of whether make should be executed subsequently when used via `:AutoMaque`. If
none of these exist, the plugin's default setter is used.

There are two functions that make convenient and persistent configuration of
commands and panes possible, to be used in filetype or project config:

- `maque#add_command('name', 'command', options)` can be used to create a command.
- `maque#tmux#add_pane('name', options)` creates a new pane that can be used
  from commands by specifying its name in the options dictionary.

## Details

The default assembly method uses `'makeprg'` as executable, so `:compiler` can
be used to configure maque. If a global or buffer-local variable
`maque_args_{&makeprg}` is set, it is always appended to the command line. The
first execution of `:AutoMaque` should be done with the cursor on the desired
unittest.

After storing information about the currently selected environment, custom
mappings can launch different commands in conque or tmux (See the
puppet-vagrant functions for an example).

## tmux

The tmux method is designed to maintain a persistently open pane for
maqueprg execution. Before and after each test execution, output redirection to
a temp file is (de)activated.
The command `:MaqueTmuxToggle` is provided to manually kill or open the tmux
pane.

The main pane is created as a horizontal split by default, but you can specify
an arbitrary system command via `g:maque_tmux_main_split_cmd`. You can even
launch a new session in a fresh terminal by setting the variable to `'TMUX=
urxvt -e tmux &!'` (note that tmux will not nest, indicated by the `$TMUX`
environment variable). As long as as the pane is on localhost, it will be
found.

There are two commands available to create additional panes:

`:MaqueTmuxAddPane name ['tmux split command']` creates a named pane which can
be used by specifying its name as first argument to `:Maque`.
To use a different pane as default execution target, run `:MaqueTmuxCycle` or
assign its name to `g:maque_tmux_current_pane`.

`:MaqueTmuxBuffer` and `:MaqueTmuxDebuffer` create and destroy a pane that is
associated with the current buffer and will receive all makes executed from it.

`:MaqueTmuxKill` will successively send the signals in
`g:maque_tmux_kill_signals` to the process running in the current pane on each
invocation, until the process has terminated. The default is INT, TERM, KILL.

You can send a custom signal by specifying it, like `:MaqueTmuxKill HUP`.


## CtrlP

Maque provides two CtrlP-menus, `:CtrlPMaque` for displaying and executing
available commands, and `:CtrlPMaqueTmux` for displaying created panes and
setting the active pane.

## Example

When editing an rspec file, the default `maque_args` are set to `--drb`. When
invoking the `<Plug>(auto-maque)` mapping, the default makeprg setter appends
`spec/current_file_spec.rb:23`, given that the cursor is on line 23. The whole
command line then becomes `rspec --drb spec/current_file_spec.rb:23`, which
will run only the example (group) under the cursor.

## License

Copyright (c) Torsten Schmits. Distributed under the terms of the
[MIT License](http://opensource.org/licenses/MIT 'mit license').

[1]: http://gentoo64.net/maque_basic.gif
