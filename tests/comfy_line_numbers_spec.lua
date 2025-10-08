-- requires 'nvim-lua/plenary.nvim'
-- TODO how do we specify requirements for the plugin?

describe("comfy_line_numbers", function()
  it("can be required", function()
    require "comfy-line-numbers"
  end)

  -- it("should say ", function()
  --   local plugin = require('comfy-line-numbers')
  --   assert.equals("Hello from plugin-template!!!", plugin._greeting())
  -- end)
end)
