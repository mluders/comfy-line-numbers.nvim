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

 -- Reduce/Increase the width of the statuscolumn
  min_numberwidth = 3,

  -- Enable integration with gitsigns.nvim
  gitsigns = {
    enabled = true,
  }

  -- Line numbers will be completely hidden for the following file/buffer types
  hidden_file_types = { 'undotree' },
  hidden_buffer_types = { 'terminal', 'nofile' }
})
```

## Hooks

Here is an example of a hook that highlights your favorite line number in a different color.

```lua
local comfy = require 'comfy-line-numbers'
local function strip_padding(str)
  return str:gsub("^%s+", "")
end
comfy.register_line_hook('my_hook', function(lnum, data)
  -- data contains: { num = <string>, diag = <string>, git = <string> }
  -- num for line number text, diag for diagnostics text, git for git signs text
  -- The text can contain highlight groups.
  if lnum == 42 then
    local stripped = strip_padding(data.num)
    data.num = '%#ErrorMsg#' .. stripped .. '%*'
  end
  return data
end)
```

If you where to add text into the statuscolumn, prefer adding it to data.num and don't forget to take that into account when setting
`min_numberwidth`, otherwise the statuscolumn might shift when the line number changes.

## Commands

| Command | Description |
|---------|-------------|
| `:ComfyLineNumbers enable` | Enable comfy line numbers |
| `:ComfyLineNumbers disable` | Disable comfy line numbers |
| `:ComfyLineNumbers toggle` | Toggle comfy line numbers on/off |
| `:ComfyLineNumbers toggle_signs` | Toggle git signs display |

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


