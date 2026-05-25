-- requires 'nvim-lua/plenary.nvim'
-- TODO how do we specify requirements for the plugin?

describe("comfy_line_numbers", function()
  it("can be required", function()
    require('comfy-line-numbers')
  end)

  it("does not overwrite floating window statuscolumns", function()
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, false, {
      relative = 'editor',
      row = 0,
      col = 0,
      width = 20,
      height = 1,
      style = 'minimal',
    })

    vim.api.nvim_set_option_value('statuscolumn', 'FLOAT', { scope = 'local', win = win })

    require('comfy-line-numbers').setup()

    assert.equals('FLOAT', vim.api.nvim_get_option_value('statuscolumn', { scope = 'local', win = win }))

    vim.api.nvim_win_close(win, true)
  end)

  -- it("should say ", function()
  --   local plugin = require('comfy-line-numbers')
  --   assert.equals("Hello from plugin-template!!!", plugin._greeting())
  -- end)
end)
