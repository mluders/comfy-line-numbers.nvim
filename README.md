# Comfy Line Numbers

A Neovim plugin that makes vertical motions more comfortable.

![comfy_demo](https://github.com/user-attachments/assets/e59f61f3-a2e7-48be-966a-db7543ed0a82)

## The problem

I love using relative line numbers for vertical movement. But I've noticed a problem...

* `6j`
* `19k`
* `18j`

What do these motions have in common? The right-hand fingers are overloaded, having to jump between numbers and letters.

It's too much movement.

## The solution

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

## How it works

1. Relative line numbers are displayed in status column (with right-hand digits omitted).

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
  labels = {
    '1', '2', '3', '4', '5', '11', '12', '13', '14', '15',
    '21', '22', '23', '24', '25', '31', '32', '33', '34', '35',
    '41', '42', '43', '44', '45', '51', '52', '53', '54', '55',
  }
  up_key = 'j'
  down_key = 'k'
  enable_in_terminal = false
})
```

## Limitations

* When `enable_in_terminal` is false, an empty status column is still visible in the terminal (see [a67c19e](https://github.com/mluders/comfy-line-numbers.nvim/commit/a67c19ea1975674f08678269af85bf388d59b1ef) for more details).

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


