## Description

**maque** executes alternative methods to vim's :make command.

[Conque](https://github.com/rson/vim-conque 'github repo'),
[tmux](https://github.com/erwandev/screen 'github repo') and
[dispatch](https://github.com/tpope/vim-dispatch 'github repo')

are currently supported methods.

## Usage

Convenience mappings:  
`<Plug>Maque` executes `makeprg`  
`<Plug>AutoMaque` calls a `makeprg` setter function and executes it.  
`<Plug>MaqueParse` populates the quickfix list using `'errorformat'`  

## Customization

To add your own `make` replacement, assign a function name to `g:maque_maker`.

To replace the default `makeprg` assembly methods, assign yours to
`b:maque_makeprg_setter` or `g:maque_makeprg_setter`, or define the function
`maque#ft#{&filetype}#set_makeprg`.
If none of these exist, the plugin's default setter is used.

## Details

The main purpose of **maque** is to to assemble test invocation commands for
various filetypes and manage different test command dispatching methods. The
first execution of `AutoMaque` should be done with the cursor on the desired
unittest. After storing information about the currently selected environment,
custom mappings can launch different commands in conque or tmux (See the puppet
functions for an example).

The tmux method is designed to maintain a permanently open pane for
dispatching. Before and after each test execution, output redirection to a temp
file is (de)activated.

After having executed a test, `<Plug>MaqueParse` executes `:cgetfile`, which
populates the quickfix list identically to how :make does.
