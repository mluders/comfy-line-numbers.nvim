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

## Customization

### Simple Configuration (Recommended)

The plugin automatically generates labels based on `base` and `max_digits`:

```lua
require('comfy-line-numbers').setup({
  base = 5,         -- Use digits 1-5 (default). Can be 3-9.
  max_digits = 10,  -- Generate up to 10-digit combinations (default)
  up_key = 'k',
  down_key = 'j',

  -- Line numbers will be completely hidden for the following file/buffer types
  hidden_file_types = { 'undotree' },
  hidden_buffer_types = { 'terminal', 'nofile' }
})
```

**Defaults:** `base = 5`, `max_digits = 10` → **12,207,030 combinations** (you'll never run out!)

### Base and Max Digits Options

**Base** determines which digits are used:
- `base = 3`: Uses digits {1, 2, 3}
- `base = 4`: Uses digits {1, 2, 3, 4}
- `base = 5`: Uses digits {1, 2, 3, 4, 5} (default)
- ... up to `base = 9`

**Max Digits** determines the longest label:
- `max_digits = 3`: Labels up to 3 digits (e.g., 555)
- `max_digits = 5`: Labels up to 5 digits (e.g., 55555)
- `max_digits = 10`: Labels up to 10 digits (default)

**Minimum requirement:** Your configuration must yield at least 100 combinations. The plugin will error if this isn't met.

### Advanced: Manual Labels

For complete control, specify labels manually (this overrides `base` and `max_digits`):

```lua
require('comfy-line-numbers').setup({
  labels = {
    '1', '2', '3', '4', '5', '11', '12', '13', '14', '15', '21', '22', '23',
    '24', '25', '31', '32', '33', '34', '35', '41', '42', '43', '44', '45',
    '51', '52', '53', '54', '55', '111', '112', '113', '114', '115', '121',
    '122', '123', '124', '125', '131', '132', '133', '134', '135', '141',
    '142', '143', '144', '145', '151', '152', '153', '154', '155', '211',
    '212', '213', '214', '215', '221', '222', '223', '224', '225', '231',
    '232', '233', '234', '235', '241', '242', '243', '244', '245', '251',
    '252', '253', '254', '255',
  },
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


