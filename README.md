# Comfy Line Numbers

A Neovim plugin that makes vertical motions more comfortable.

# The problem

I love using relative line numbers for vertical movement. But I've noticed a problem...

* `6j`
* `19k`
* `18j`

What do these motions have in common? The right-hand fingers are overloaded, having to jump between numbers and letters.

It's too much movement.

# The solution

Represent line numbers using left-hand digits:

1\
2\
3\
4\
5\
11\
12\
13\
14\
15\
21\
22\
...\
55

This lets your left hand focus on digits, while your right hand focuses on `j` and `k`.

Less movement. More comfort.

# How it works

1. Relative line numbers are displayed using statuscolumn (with right-hand digits omitted).

2. Vertical motions are re-mapped to their original meanings:
    * `11j` becomes `6j`
    * `34k` becomes `19k`
    * `33j` becomes `18j`
    * etc.

## Installation

Using your plugin manager of choice (lazy.nvim in the example below):

```lua
return {
  'mluders/comfy-line-numbers.nvim'
}
```

Make sure line numbers are enabled:

```lua
vim.opt.number = true
```

## Customization

```lua
require('comfy-line-numbers').setup({
  -- Override the default line numbers with your own list:
  -- labels = {
    -- '1',
    -- '2',
    -- '3',
    -- '4',
    -- '5',
    -- '11',
    -- '12',
    -- '13',
    -- '14',
    -- '15',
    -- '21',
    -- '22',
    -- ...
    -- '55',
  -- }
  --
  -- Override up/down mappings
  -- up_key = 'j'
  -- down_key = 'k'
})
```

## Limitations

* Right-hand digits are ommitted by default. This means you can only jump 25 lines in each direction. You can easily add more line numbers by overriding `labels` (see [customization](#customization)).
* Line numbers cannot exceed 2 digits. The reason is because they're rendered in a single sign column (which is limited to 2 characters).
* The current line number is rendered as a static string (defaults to `=>`). The reason is the same as above: sign columns are limited to two characters.

## Testing

The specs use [plenary.nvim tests](https://github.com/nvim-lua/plenary.nvim/blob/master/TESTS_README.md).

To run the spec in the current buffer:
```vim
:PlenaryBustedFile %
```
To run all of the specs:
```vim
:PlenaryBustedDirectory tests
```
Note: The tests run in a remote nvim instance and display output in a new window in terminal mode.
You may need to C-\ C-n to switch back to NORMAL mode and close the window.

Optionally, you can run the tests from the command line. Here is an ex command that opens a new terminal
in a split window and runs all the tests:
```vim
:split term://nvim --headless -c 'PlenaryBustedDirectory tests'
```


