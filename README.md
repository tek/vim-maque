## Description

**maque** executes alternative methods to vim's :make command and assists in
assembling command lines.

[Conque](https://github.com/rson/vim-conque 'github repo'),
[tmux](https://github.com/erwandev/screen 'github repo') and
[dispatch](https://github.com/tpope/vim-dispatch 'github repo')

are currently supported methods.

## Usage

Convenience mappings:  
`<Plug>Maque` executes `g:maqueprg`  
`<Plug>AutoMaque` calls a `g:maqueprg` setter function and executes it.  
`<Plug>MaqueParse` populates the quickfix list using `'errorformat'`  

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

The tmux method is designed to maintain a permanently open pane for
dispatching. Before and after each test execution, output redirection to a temp
file is (de)activated.

After having executed a test, `<Plug>MaqueParse` executes `:cgetfile`, which
populates the quickfix list identically to how :make does.

## Example

When editing an rspec file, the default `maque_args` are set to `--drb`. When
invoking the `<Plug>AutoMaque` mapping, the default makeprg setter appends
`spec/current_file_spec.rb:23`, given that the cursor is on line 23. The whole
command line then becomes `rspec --drb spec/current_file_spec.rb:23`, which
will run only the example (group) under the cursor.
