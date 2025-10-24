# Comfy Line Numbers

A Neovim plugin that makes vertical motions more comfortable.

This is a branch of the original repo
## Add feature:
- add a fun called 'gen_label' to generate label at ease
- consecutive numbers can be trimmed if wantted (gen_label has 4 params, when the 4th one isnt empty it is the very consecutive number)
- i.e.
```lua
-- base is [1,2,3]
-- depth is 4
gen_label(1,3,4)
-- base is [1,2,3,4,5]
-- depth is 3
gen_label(1,5,3)
-- base is [1,2,3]
-- depth is 4
-- all consecutive 2s are trimmed which means "22", "122", or "322" are gone
gen_label(1,3,4,2)
```

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
  'MrKyomoto/comfy-line-numbers.nvim'
}
```

## Customization

```lua
local gen_labels = require("comfy-line-numbers.custom_labels").gen_labels
require('comfy-line-numbers').setup({
  -- gen_labels(start, end_, depth)
  -- start: default value is 1, must be a number, in [0,8]
  -- end_: default value is 3, must be a number, in [2,9]
  -- depth: default value is 3, must be a number, in [1,9]
  labels = gen_labels(1,4,3),
  up_key = 'k',
  down_key = 'j',

  -- Line numbers will be completely hidden for the following file/buffer types
  hidden_file_types = { 'undotree' },
  hidden_buffer_types = { 'terminal', 'nofile' }
})
```

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


