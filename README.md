## Description

**maque** executes alternative methods to vim's :make command.

[Conque](https://github.com/rson/vim-conque 'github repo') and
[tmux](https://github.com/erwandev/screen 'github repo')
are currently supported methods.

## Usage

Convenience mappings:  
`<Plug>Maque` executes `makeprg`  
`<Plug>AutoMaque` calls a `makeprg` setter function and executes it.  
`<Plug>MaqueParseOutput` populates the quickfix list using `'errorformat'`  

## Customization

To add your own `make` replacement, assign a function name to `g:maque_maker`.

To replace the default `makeprg` assembly methods, assign yours to
`b:maque_makeprg_setter` or `g:maque_makeprg_setter`.  
If none of these exist, the plugin's default setter is used.

## Details

The main purpose of **maque** is to manage conque and to assemble test
invocation commands for various filetypes. The first execution of `AutoMaque`
should be done with the cursor on the desired unittest. After storing
information about the currently selected environment, custom mappings can
launch different commands in conque or tmux (See the puppet functions for an
example).

After having executed a test, `<Plug>MaqueParseOutput` writes the output to
`'errorfile'` and executes `:cgetfile`, which populates the quickfix list
identically to how :make does.
